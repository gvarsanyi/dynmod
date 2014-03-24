child_process = require 'child_process'
exec_sync     = require 'sync-exec'

list = require './list'


module.exports = (pkg, callback) ->
  return callback(new Error 'Version is not required') if pkg.indexOf('@') > -1

  cmd = 'npm show ' + pkg + ' version 2> /dev/null'
  child_process.exec cmd, (err, stdout, stderr) ->
    return callback(err) if err
    current = stdout.replace /^\s+|\s+$/g, '' # trim
    list pkg, (err, versions) ->
      callback null, current, versions and current in versions, versions

module.exports.sync = (pkg) ->
  return callback(new Error 'Version is not required') if pkg.indexOf('@') > -1

  {status, stdout, stderr} = exec_sync 'npm show ' + pkg + ' version'
  throw new Error(stderr) if status
  current  = stdout.replace /^\s+|\s+$/g, '' # trim
  versions = list.sync pkg
  [current, versions and current in versions, versions]
