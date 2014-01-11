try config = require '../config.json'

unless typeof config?.port is 'number' and typeof config?.targets is 'object'
  if process.argv[2] is 'config'
    config = {}
  else
    console.log 'ERROR: configuration required. Run:'
    console.log 'vhostd config'
    process.exit 1

module.exports = config
