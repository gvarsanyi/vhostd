child_process = require 'child_process'
fs            = require 'fs'
iniparser     = require 'iniparser'

stderr = require './stderr'

file_name = '/etc/vhostd.ini'

config               = null
server_port          = null
suspended            = 'booting'
start_event_bindings = []
stop_event_bindings  = []
watcher              = null

module.exports =
  attachStartEvent: (callback) -> start_event_bindings.push callback
  attachStopEvent: (callback) -> stop_event_bindings.push callback
  getPort: -> server_port
  getTarget: (hostname) -> config[hostname]
  isRunnable: -> not suspended

suspend = (reason) ->
  console.log '[' + (new Date).toUTCString() + '] Suspending for: ' + reason
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
    suspend 'config file changed, restarting'
    child_process.exec 'nohup vhostd restart > /dev/null 2>&1 &'
    process.exit 0

  fs.readFile file_name, encoding: 'utf8', (err, data) ->
    return suspend(err) if err

    try inf = iniparser.parseString data

    unless validate_port Number inf?.SERVER?.port
      return suspend 'missing or invalid port config'

    server_port = Number inf.SERVER.port

    count = 0
    aliases = {}
    config  = {}
    for target, spec of inf when target isnt 'SERVER'
      if spec.ref?
        if spec.address? and spec.port?
          if validate_port Number spec.port and spec.address.length
            stderr 'skipping ref from ambiguos target:', target
            config[target] =
              host: spec.address
              port: spec.port
            count += 1
          else
            stderr 'skipping invalid target:', target
        else
          aliases[target] = spec.ref
          if spec.address? or spec.port?
            stderr 'skipping address/port from ambiguos target:', target
      else unless validate_port Number spec.port and spec.address.length
        stderr 'skipping invalid target:', target
      else
        config[target] =
          host: spec.address
          port: spec.port
        count += 1

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
