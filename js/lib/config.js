// Generated by CoffeeScript 1.6.3
(function() {
  var child_process, config, file_name, fs, iniparser, load, resume, server_port, start_event_bindings, stderr, stop_event_bindings, suspend, suspended, validate_port, watcher;

  child_process = require('child_process');

  fs = require('fs');

  iniparser = require('iniparser');

  stderr = require('./stderr');

  file_name = '/etc/vhostd.ini';

  config = null;

  server_port = null;

  suspended = 'booting';

  start_event_bindings = [];

  stop_event_bindings = [];

  watcher = null;

  module.exports = {
    attachStartEvent: function(callback) {
      return start_event_bindings.push(callback);
    },
    attachStopEvent: function(callback) {
      return stop_event_bindings.push(callback);
    },
    getPort: function() {
      return server_port;
    },
    getTarget: function(hostname) {
      return config[hostname];
    },
    isRunnable: function() {
      return !suspended;
    }
  };

  suspend = function(reason) {
    var callback, was_suspended, _i, _len, _results;
    console.log('[' + (new Date).toUTCString() + '] Suspending for: ' + reason);
    was_suspended = suspended;
    suspended = reason;
    if (!was_suspended) {
      _results = [];
      for (_i = 0, _len = stop_event_bindings.length; _i < _len; _i++) {
        callback = stop_event_bindings[_i];
        _results.push(callback());
      }
      return _results;
    }
  };

  resume = function() {
    var callback, was_suspended, _i, _len, _results;
    was_suspended = suspended;
    suspended = false;
    if (was_suspended) {
      _results = [];
      for (_i = 0, _len = start_event_bindings.length; _i < _len; _i++) {
        callback = start_event_bindings[_i];
        _results.push(callback());
      }
      return _results;
    }
  };

  validate_port = function(port) {
    return typeof port === 'number' && port > 0 && port < 49151 && port % 1 === 0;
  };

  load = function() {
    if (watcher) {
      watcher.close();
    }
    try {
      watcher = fs.watch(file_name, function(event) {
        suspend('config file changed, restarting');
        child_process.exec('nohup vhostd restart > /dev/null 2>&1 &');
        return process.exit(0);
      });
    } catch (_error) {}
    return fs.readFile(file_name, {
      encoding: 'utf8'
    }, function(err, data) {
      var alias, aliases, count, found_one, inf, spec, target, _ref;
      if (err) {
        return suspend(err);
      }
      try {
        inf = iniparser.parseString(data);
      } catch (_error) {}
      if (!validate_port(Number(inf != null ? (_ref = inf.SERVER) != null ? _ref.port : void 0 : void 0))) {
        return suspend('missing or invalid port config');
      }
      server_port = Number(inf.SERVER.port);
      count = 0;
      aliases = {};
      config = {};
      for (target in inf) {
        spec = inf[target];
        if (target !== 'SERVER') {
          if (spec.ref != null) {
            if ((spec.address != null) && (spec.port != null)) {
              if (validate_port(Number(spec.port && spec.address.length))) {
                stderr('skipping ref from ambiguos target:', target);
                config[target] = {
                  host: spec.address,
                  port: spec.port
                };
                count += 1;
              } else {
                stderr('skipping invalid target:', target);
              }
            } else {
              aliases[target] = spec.ref;
              if ((spec.address != null) || (spec.port != null)) {
                stderr('skipping address/port from ambiguos target:', target);
              }
            }
          } else if (!validate_port(Number(spec.port && spec.address.length))) {
            stderr('skipping invalid target:', target);
          } else {
            config[target] = {
              host: spec.address,
              port: spec.port
            };
            count += 1;
          }
        }
      }
      found_one = count;
      while (found_one) {
        found_one = false;
        for (alias in aliases) {
          target = aliases[alias];
          if (config[target] != null) {
            config[alias] = config[target];
            delete aliases[alias];
            found_one = true;
          }
        }
      }
      for (alias in aliases) {
        target = aliases[alias];
        stderr('skipping reference without existing target:', alias);
      }
      if (!count) {
        return suspend('no valid target was found');
      }
      return resume();
    });
  };

  fs.exists(file_name, function(exists) {
    var cfg_str;
    if (exists) {
      return load();
    }
    cfg_str = '[SERVER]\nport = 80\n\n' + '[example.com]\naddress = 127.0.0.1\nport = 8000\n\n' + '[alias.example.com]\nref = example.com\n\n' + '[other.com]\naddress = 127.0.0.1\nport = 9000\n';
    return fs.writeFile(file_name, cfg_str, {
      encoding: 'utf8'
    }, function(err) {
      if (err) {
        stderr('ERROR: ' + file_name + ' missing, cant create it.');
        process.exit(1);
      }
      return load();
    });
  });

}).call(this);