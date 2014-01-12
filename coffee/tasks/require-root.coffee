
unless process.getuid() is 0
  process.stderr.write 'Root is required\n'
  process.exit 1
