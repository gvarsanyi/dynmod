fs = require 'fs'

cache    = require '../cache'
current  = require './current'
dir      = require '../dir'
list_all = require './list-all'


module.exports = (pkg, callback) ->
  return list_all(pkg) if typeof pkg is 'function'
  return list_all(callback) unless pkg
  return callback(new Error 'Version is not required') if pkg.indexOf('@') > -1

  fs.exists dir + '/' + pkg, (exists) ->
    return callback(null, false) unless exists
    fs.readdir dir + '/' + pkg, (err, versions) ->
      delete cache.current[pkg]
      return callback(null, false) unless versions.length
      if versions and versions.length
        cache.current[pkg] = versions[versions.length - 1]
      callback null, versions

module.exports.sync = (pkg) ->
  return list_all.sync() unless pkg
  throw new Error('Version is not required') if pkg.indexOf('@') > -1
  return false unless fs.existsSync dir + '/' + pkg
  versions = fs.readdirSync dir + '/' + pkg
  if versions and versions.length
    cache.current[pkg] = versions[versions.length - 1]
  versions
