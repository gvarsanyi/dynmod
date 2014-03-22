fs   = require 'fs'
util = require 'util'

dir     = require './dir'
install = require './install'
list    = require './list'


err_msg = '%s is partially installed (possibly being installed by an other pr' +
          'ocess?). If you are sure this is a failed installation, use requir' +
          'e(\'dynmod\').remove(\'%s\'); to remove it.'


module.exports = (spec, callback) ->
  [pkg, version] = spec.split '@'

  if mod = cache[pkg]?[version or currents[pkg]]?
    return callback null, mod

  read = ->
    try
      path = dir + '/' + pkg + '/' + version + '/node_modules/' + pkg
      mod = require path
      (cache[pkg] ?= {})[version] = mod
      callback null, mod
    catch err
      callback err

  verify_version = ->
    fs.exists dir + '/' + pkg + '/' + version + '/.dynmod-proper', (exists) ->
      return read() if exists
      return callback new Error util.format err_msg, spec, spec

  list pkg, (err, versions) ->
    unless version
      return callback(err) if err
      if versions and versions.length > 0
        version = versions.pop()
        verify_version()
      else
        install pkg, (err, version) ->
          return callback(err) if err
          version = versions.pop()
          verify_version()
    else if version in versions
      verify_version()
    else
      install spec, (err) ->
        return callback(err) if err
        verify_version()

module.exports.cache = cache = {}

module.exports.sync = (spec) ->
  [pkg, version] = spec.split '@'

  return mod if mod = cache[pkg]?[version or currents[pkg]]?

  versions = list.sync pkg
  unless version
    if versions and versions.length
      version = versions.pop()
    else
      version = install.sync pkg
  else unless versions and versions.length and version in versions
    install.sync spec

  unless fs.existsSync dir + '/' + pkg + '/' + version + '/.dynmod-proper'
    throw new Error util.format err_msg, spec, spec
  path = dir + '/' + pkg + '/' + version + '/node_modules/' + pkg
  require path
