// Generated by CoffeeScript 1.6.3
(function() {
  var __slice = [].slice;

  module.exports = function() {
    var out;
    out = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return process.stderr.write('[' + (new Date).toUTCString() + '] ' + out.join(' ') + '\n');
  };

}).call(this);
