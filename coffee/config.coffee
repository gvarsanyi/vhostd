fs = require 'fs'

file_name = '/etc/vhostd.json'

config               = null
suspended            = 'booting'
start_event_bindings = []
stop_event_bindings  = []
watcher              = null

module.exports =
  attachStartEvent: (callback) ->
    start_event_bindings.push callback

  attachStopEvent: (callback) ->
    stop_event_bindings.push callback

  getPort: ->
    return null if suspended
    config.port

  getTargets: ->
    return null if suspended
    config.targets

  isRunnable: ->
    not suspended


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

validate_spec = (spec) ->
  return true if typeof spec is 'string'
  if typeof spec is 'object' and spec?.length
    for host in spec
      return false unless typeof host is 'string'
    return true
  false

load = ->
  watcher.close() if watcher
  try watcher = fs.watch file_name, (event) ->
    suspend 'config file changed'
    load()

  fs.readFile file_name, encoding: 'utf8', (err, str) ->
    return suspend(err) if err

    try config = JSON.parse str

    unless validate_port config?.port
      return suspend 'missing or invalid port config'

    unless config?.targets and typeof config.targets is 'object'
      return suspend 'missing or invalid targets object in config'

    count = 0
    for target, spec of config.targets
      [host, port] = target.split ':'
      unless validate_port Number port and host.length
        process.stderr.write 'skipping invalid target "' + target + '"\n'
      else unless validate_spec spec
        process.stderr.write 'skipping target "' + target + '" with invalid ' +
                             'specs: ' + JSON.stringify(spec) + '\n'
      else
        count += 1

    unless count
      return suspend 'no valid target was found'

    resume()

fs.exists file_name, (exists) ->
  return load() if exists

  cfg_str = JSON.stringify
    port: 80,
    targets: {}
  , null, 2

  fs.writeFile file_name, cfg_str, encoding: 'utf8', (err) ->
    if err
      process.stderr.write 'ERROR: ' + file_name + ' missing, cant create it.\n'
      process.exit 1
    load()
