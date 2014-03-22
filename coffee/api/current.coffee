child_process = require 'child_process'


module.exports = (pkg, callback) ->
  return callback(new Error 'Version is not required') if pkg.indexOf('@') > -1

  cmd = 'npm show ' + pkg + ' version 2> /dev/null'
  child_process.exec cmd, (err, stdout, stderr) ->
    return callback(err) if err
    current = stdout.replace /^\s+|\s+$/g, '' # trim
    require('./list') pkg, (err, versions) ->
      callback null, current, versions and current in versions, versions

module.exports.cache = {}
