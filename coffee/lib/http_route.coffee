config     = require './config'
server_log = require './server_log'
stderr     = require './stderr'

module.exports = (req, res, proxy) ->
  try
    requested_host = String(req?.headers?.host + ':').split(':')[0]
    target = config.getTarget requested_host
 
    if target?.host and target?.port
      server_log req, target
      proxy.proxyRequest req, res, target
    else
      res.writeHead 404, 'Content-Type': 'text/plain'
      res.write 'Missing page\n'
      res.end()
      stderr 'TARGET ERROR:', JSON.stringify req.headers
  catch err
    stderr 'ERROR:', JSON.stringify err
