#!/usr/bin/coffee

try
  task = require './tasks/' + (process.argv[2] or 'server')
catch e
  throw new Error e
  process.stderr.write 'ERROR: invalid task: "' + process.argv[2] + '"\n\n'
  process.exit 1

task.run()
