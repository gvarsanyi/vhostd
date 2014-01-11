get_target = require './get_target'
log        = require './log'

module.exports = (req, res, proxy) ->
  try
    target = get_target req

    if target?.host and target?.port
      log req, target
      proxy.proxyRequest req, res, target
    else
      res.writeHead 404, 'Content-Type': 'text/plain'
      res.write 'Missing page\n'
      res.end()
      console.log '    TARGET ERROR', req.headers
  catch err
    console.log '    ERROR: ', err
