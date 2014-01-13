log = require './log'

module.exports = (req, target, protocol='http') ->
  log req.method, protocol + '://' + req.headers.host + req.url, '->',
      target.host + ':' + target.port
