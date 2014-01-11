
module.exports = (req, target, protocol='http') ->
  console.log '[' + (new Date).toUTCString() + ']', req.method,
              protocol + '://' + req.headers.host + req.url, '->',
              target.host + ':' + target.port
