child_process = require 'child_process'
fs            = require 'fs'
iniparser     = require 'iniparser'

log    = require './log'
stderr = require './stderr'

file_name = '/etc/vhostd.ini'

config               = null
server_port          = null
suspended            = 'booting'
start_event_bindings = []
stop_event_bindings  = []
watcher              = null

module.exports.attachStartEvent = (callback) ->
  start_event_bindings.push callback

module.exports.attachStopEvent = (callback) ->
  stop_event_bindings.push callback

module.exports.getPort = ->
  server_port

module.exports.getTarget = (hostname) ->
  target = config[hostname].shift()
  config[hostname].push target
  target

module.exports.isRunnable = ->
  not suspended


suspend = (reason) ->
  log 'suspending:', reason
  was_suspended = suspended
  suspended = reason
  unless was_suspended
    callback() for callback in stop_event_bindings

resume = ->
  was_suspended = suspended
  suspended = false
  if was_suspended
    callback() for callback in start_event_bindings

validate_port = (port) ->
  typeof port is 'number' and port > 0 and port < 49151 and port % 1 is 0

load = ->
  watcher.close() if watcher
  try watcher = fs.watch file_name, (event) ->
    forced_restart = ->
      suspend 'config file changed, restarting service'
      child_process.exec 'nohup vhostd restart > /dev/null 2>&1 &'
      process.exit 0

    fs.readFile file_name, encoding: 'utf8', (err, data) ->
      return forced_restart() if err

      try
        inf = iniparser.parseString data
        return load() if Number(inf?.SERVER?.port) is server_port
        forced_restart()
      catch err
        forced_restart()

  fs.readFile file_name, encoding: 'utf8', (err, data) ->
    return suspend(err) if err

    try inf = iniparser.parseString data

    unless validate_port Number inf?.SERVER?.port
      return suspend 'missing or invalid port config'

    server_port = Number inf.SERVER.port

    count = 0
    aliases = {}
    config  = {}
    parse_multi = (target, spec) ->
      normalize = (str) ->
        str = String(str).replace(',', ' ').replace('\t', ' ')
        str = str.replace('  ', ' ') while str.indexOf('  ') > -1
        str.split ' '

      addrs = normalize spec.address
      ports = normalize spec.port

      for port in ports
        unless validate_port Number port
          stderr 'skipping invalid target:', target
          return false

      targets = []
      if addrs.length > 1 and ports.length is 1
        targets.push({host, port: ports[0]}) for host in addrs
      else if addrs.length is 1 and ports.length > 1
        targets.push({host: addrs[0], port}) for port in ports
      else if addrs.length is 1 and ports.length is 1
        targets.push {host: addrs[0], port: ports[0]}
      else
        stderr 'skipping invalid target:', target
        return false

      config[target] = targets
      count += 1
      true

    for target, spec of inf when target isnt 'SERVER'
      unless spec.ref?
        parse_multi target, spec
        continue

      if spec.address? and spec.port?
        if parse_multi target, spec
          stderr 'skipping ref from ambiguos target:', target
      else
        aliases[target] = spec.ref
        if spec.address? or spec.port?
          stderr 'skipping address/port from ambiguos target:', target

    found_one = count
    while found_one
      found_one = false
      for alias, target of aliases
        if config[target]?
          config[alias] = config[target]
          delete aliases[alias]
          found_one = true

    for alias, target of aliases
      stderr 'skipping reference without existing target:', alias

    unless count
      return suspend 'no valid target was found'

    log 'config file', file_name, 'loaded'
    resume()

fs.exists file_name, (exists) ->
  return load() if exists

  cfg_str = '[SERVER]\nport = 80\n\n' +
            '[example.com]\naddress = 127.0.0.1\nport = 8000\n\n' +
            '[alias.example.com]\nref = example.com\n\n' +
            '[other.com]\naddress = 127.0.0.1\nport = 9000\n'

  fs.writeFile file_name, cfg_str, encoding: 'utf8', (err) ->
    if err
      stderr 'ERROR: ' + file_name + ' missing, cant create it.'
      process.exit 1
    load()
