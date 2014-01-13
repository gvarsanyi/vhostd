
module.exports = (out...) ->
  process.stderr.write '[' + (new Date).toUTCString() + '] ' +
                       out.join(' ') + '\n'
