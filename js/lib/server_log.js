// Generated by CoffeeScript 1.6.3
(function() {
  var log;

  log = require('./log');

  module.exports = function(req, target, protocol) {
    if (protocol == null) {
      protocol = 'http';
    }
    return log(req.method, protocol + '://' + req.headers.host + req.url, '->', target.host + ':' + target.port);
  };

}).call(this);