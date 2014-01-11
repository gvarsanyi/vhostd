config = require '../config'

if config.port <= 1024 and process.getuid() isnt 0
  process.stderr.write 'Privileged port ' + config.port + ' requires root\n'
  process.exit 1
else if process.argv[2] is 'test-privilege'
  console.log 'Privileges OK'
  process.exit 0
