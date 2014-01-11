fs         = require 'fs'
httpProxy  = require 'http-proxy'
config     = require '../config'
http_route = require '../http_route'
log        = require '../log'
ws_route   = require '../ws_route'

module.exports.run = ->
  require './test-privilege'

  module.exports.server = httpProxy
    .createServer(http_route)
    .on('upgrade', ws_route)
    .listen(config.port)

  console.log '[' + (new Date).toUTCString() + '] listening @ port', config.port
