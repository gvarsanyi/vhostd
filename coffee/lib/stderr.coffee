t = require './t'

module.exports = (out...) ->
  out.unshift t()
  process.stderr.write out.join(' ') + '\n'
