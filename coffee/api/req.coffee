fs = require 'fs'

dir     = require './dir'
install = require './install'
list    = require './list'


read = (pkg, version, callback) ->
  try
    path = dir + '/' + pkg + '/' + version + '/node_modules/' + pkg
    mod = require path
    (cache[pkg] ?= {})[version] = mod
    callback null, mod
  catch err
    callback err


module.exports = (spec, callback) ->
  [pkg, version] = spec.split '@'

  if mod = cache[pkg]?[version or currents[pkg]]?
    return callback null, mod

  verify_version = ->
    fs.exists dir + '/' + pkg + '/' + version + '/.dynmod-proper', (exists) ->
      return read(pkg, version, callback) if exists
      msg = pkg + '@' + version + ' is partially installed (possibly being ' +
            'installed by an other process?). If you are sure this is a ' +
            'failed installation, use require(\'dynmod\').remove(\'' + pkg +
            '\', \'' + version + '\'); to remove it.'
      return callback new Error msg

  unless version
    list pkg, (err, versions) ->
      return callback(err) if err
      if versions and versions.length > 0
        version = versions.pop()
        verify_version()
      else
        install pkg, (err, version) ->
          return callback(err) if err
          version = versions.pop()
          verify_version()
  else
    verify_version()

module.exports.cache = cache = {}
