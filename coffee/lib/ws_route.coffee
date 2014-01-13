config     = require './config'
server_log = require './log'
stderr     = require './stderr'

module.exports = (req, socket, head) ->
  try
    requested_host = String(req?.headers?.host + ':').split(':')[0]
    target = config.getTarget requested_host

    if target?.host and target?.port
      server_log req, target, 'ws'
      server.proxy.proxyWebSocketRequest req, socket, head, target
    else
      throw new Error 'No valid target for websocket' # or just let it die
  catch err
    stderr 'ERROR:', JSON.stringify err
