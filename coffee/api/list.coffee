fs = require 'fs'

current = require './current'
dir     = require './dir'


module.exports = (pkg, callback) ->
  return require('./list-all')(pkg) if typeof pkg is 'function'
  return require('./list-all')(callback) unless pkg
  return callback(new Error 'Version is not required') if pkg.indexOf('@') > -1

  fs.exists dir + '/' + pkg, (exists) ->
    return callback(null, false) unless exists
    fs.readdir dir + '/' + pkg, (err, versions) ->
      delete current.cache[pkg]
      return callback(null, false) unless versions.length
      if versions and versions.length
        current.cache[pkg] = versions[versions.length - 1]
      callback null, versions
