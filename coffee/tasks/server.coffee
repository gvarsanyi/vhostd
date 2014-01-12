require './require-root'

fs         = require 'fs'
httpProxy  = require 'http-proxy'
config     = require '../config'
http_route = require '../http_route'
ws_route   = require '../ws_route'

server            = null
restart_requested = null
stop_requested    = false
server_running    = false

start = ->
  server = httpProxy
    .createServer(http_route)
    .on('upgrade', ws_route)
    .listen(config.getPort())

  server_running = true
  console.log '[' + (new Date).toUTCString() + '] listening @ port',
              config.getPort()

stop = (restart) ->
  restart_requested = restart_requested or restart
  if server_running and not stop_requested
    stop_requested = true
    console.log '[' + (new Date).toUTCString() + '] stopping service ' +
                '(this may take a while)'
    server.close ->
      console.log '[' + (new Date).toUTCString() + '] stopped'
      server_running = false
      stop_requested = false
      if restart_requested
        restart_requested = false
        start()
  else if not server_running and restart_requested
    restart_requested = false
    start()

module.exports.run = ->
  config.attachStartEvent -> stop(true)
  config.attachStopEvent stop

  start() if config.isRunnable()
