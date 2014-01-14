child_process = require 'child_process'

module.exports = (callback) ->
  child_process.exec 'ps aux', (err, stdout) ->
    return callback(err) if err

    for line in stdout.split '\n'
      if line.indexOf('vhostd-service') > -1
        pid_line = line
        break

    return callback(null, null) unless pid_line

    pid_line = pid_line.replace('  ', ' ') while pid_line.indexOf('  ') > -1
    pid = pid_line.split(' ')[1]

    return callback(null, null) unless pid > 0 and pid < 65536 and pid % 1 is 0

    callback null, Number pid
