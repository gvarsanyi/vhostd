// Generated by CoffeeScript 1.6.3
(function() {
  var t,
    __slice = [].slice;

  t = require('./t');

  module.exports = function() {
    var out;
    out = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return console.log(t(), out.join(' '));
  };

}).call(this);
