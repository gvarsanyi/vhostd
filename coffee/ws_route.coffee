get_target = require './get_target'
log        = require './log'

module.exports = (req, socket, head) ->
  try
    target = get_target req

    if target?.host and target?.port
      log req, target, 'ws'
      server.proxy.proxyWebSocketRequest req, socket, head, target
    else
      throw new Error 'No valid target for websocket' # or just let it die
  catch err
    console.log '    WS-ERROR: ', JSON.stringify(err)
