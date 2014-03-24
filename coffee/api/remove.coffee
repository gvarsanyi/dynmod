child_process = require 'child_process'
exec_sync     = require 'sync-exec'
fs            = require 'fs'

cache = require '../cache'
dir   = require '../dir'


common = (spec) ->
  [pkg, version] = spec.split '@'

  console.log '[dynmod] removing ' + spec
  if version
    delete cache.pkg[pkg][version] if cache.pkg[pkg]?
    rm_dir = dir + '/' + pkg + '/' + version
  else
    delete cache.pkg[pkg]
    rm_dir = dir + '/' + pkg

  [pkg, version, rm_dir]


module.exports = (spec, callback) ->
  [pkg, version, rm_dir] = common spec
  fs.exists rm_dir, (exists) ->
    return callback(new Error spec + ' is not installed') unless exists
    child_process.exec 'rm -rf ' + rm_dir, (err) ->
      return callback(err) if err
      return callback() unless version
      fs.readdir dir + '/' + pkg, (err, files) ->
        return callback() if err or (files and files.length)
        child_process.exec 'rm -rf ' + dir + '/' + pkg, (err) ->
          callback()

module.exports.sync = (spec) ->
  [pkg, version, rm_dir] = common spec

  throw new Error(spec + ' is not installed') unless fs.existsSync rm_dir

  exec_sync 'rm -rf ' + rm_dir
  return true unless version

  files = fs.readdirSync dir + '/' + pkg
  unless files and files.length
    exec_sync 'rm -rf ' + dir + '/' + pkg
  true
