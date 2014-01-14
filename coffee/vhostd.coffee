#!/usr/bin/coffee

child_process = require 'child_process'

get_pid = require './lib/get_pid'
log     = require './lib/log'
stderr  = require './lib/stderr'

task = process.argv[2] or 'soft-start'


start = ->
  require './tasks/require-root'
  process.chdir __dirname
  cmd = 'nohup ./vhostd-service.js >> /var/log/vhostd 2>&1 &'
  child_process.exec cmd, (err) ->
    return stderr('ERROR', err) if err
    get_pid (err, pid) ->
      if not err and pid
        log 'started:', pid
      else
        stderr 'attempted to start, but can not find pid. Check /var/log/vhostd'

stop = (pid, callback) ->
  check = ->
    get_pid (err, instance_pid) ->
      if instance_pid
        if check_intervals.length
          setTimeout check, check_intervals.shift()
        else
          stderr 'previous instance is not responsive, force-killing it'
          try process.kill pid, 'SIGKILL'
          setTimeout ->
            get_pid (err, instance_pid) ->
              if instance_pid
                stderr 'could not kill previous instance: ' + pid
                process.exit 1
              log 'stopped'
              callback() if callback
          , 500
      else
        log 'stopped'
        callback() if callback

  require './tasks/require-root'
  log 'stopping vhostd process:', pid
  try process.kill pid
  check_intervals = [50, 150, 300, 500, 500, 500] # .05, .2, .5, 1, 1.5, 2, kill
  setTimeout check, check_intervals.shift()

get_pid (err, pid) ->
  if err
    stderr err
    process.exit 1

  switch task
    when 'restart'
      return stop(pid, start) if pid
      log 'vhostd service is not running'
      start()
    when 'start'
      return start() unless pid
      log 'vhostd service is already running'
      return stop(pid, start)
    when 'soft-start'
      return log('vhostd service is already running') if pid
      start()
    when 'stop'
      return log('vhostd service was not running') unless pid
      stop pid
    when 'status'
      log 'vhostd service is ' + (if pid then 'running: ' + pid else 'stopped')
    else
      stderr '[vhostd] unknown task:', task
      process.exit 1
