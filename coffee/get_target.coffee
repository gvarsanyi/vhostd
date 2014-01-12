config = require './config'

module.exports = (req) ->
  Target = (target) ->
    [host, port] = target.split ':'
    {host, port: Number port}

  requested_host = (req.headers.host + ':').split(':')[0]

  for target, data of config.getTargets()
    if data is requested_host
      return new Target target
    else if typeof data is 'object' # list of vhosts
      for item in data
        if item is requested_host
          return new Target target
  null
