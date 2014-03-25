fs   = require 'fs'
util = require 'util'

cache   = require '../cache'
dir     = require '../dir'
install = require './install'
list    = require './list'


err_msg = '%s is partially installed (possibly being installed by an other pr' +
          'ocess?). If you are sure this is a failed installation, use requir' +
          'e(\'dynmod\').remove(\'%s\'); to remove it.'

async = (specs, callback) ->
  return callback(new Error 'A module name is required') unless specs.length

  errors  = []
  modules = {}
  count   = 0
  total   = specs.length

  read_spec = (spec) ->
    modules[spec] = null

    conclude = (err, mod) ->
      count += 1
      errors.push(err) if err
      modules[spec] = mod

      if count >= total
        response = []
        response.push(mod) for spec, mod of modules
        if errors.length is 1
          callback errors[0], response...
        else if errors.length > 1
          callback errors, response...
        else
          callback null, response...

    [pkg, version] = spec.split '@'

    if (mod = cache.pkg[pkg]?[version or cache.current[pkg]])?
      return conclude null, mod

    read = ->
      try
        path = dir + '/' + pkg + '/' + version + '/node_modules/' + pkg
        mod = require path
        (cache.pkg[pkg] ?= {})[version] = mod
        conclude null, mod
      catch err
        conclude err

    verify_version = ->
      fs.exists dir + '/' + pkg + '/' + version + '/.dynmod-proper', (exists) ->
        return read() if exists
        return conclude new Error util.format err_msg, spec, spec

    list pkg, (err, versions) ->
      unless version
        return conclude(err) if err
        if versions and versions.length > 0
          version = versions.pop()
          verify_version()
        else
          install pkg, (err, _version) ->
            return conclude(err) if err
            version = _version
            verify_version()
      else if version in versions
        verify_version()
      else
        install spec, (err) ->
          return conclude(err) if err
          verify_version()

  read_spec(spec) for spec in specs

sync = (specs) ->
  throw new Error('A module name is required') unless specs.length
  modules = []

  for spec in specs
    [pkg, version] = spec.split '@'

    return mod if mod = cache.pkg[pkg]?[version or cache.current[pkg]]?

    versions = list pkg
    unless version
      if versions and versions.length
        version = versions.pop()
      else
        version = install pkg
    else unless versions and versions.length and version in versions
      install spec

    unless fs.existsSync dir + '/' + pkg + '/' + version + '/.dynmod-proper'
      throw new Error util.format err_msg, spec, spec
    path = dir + '/' + pkg + '/' + version + '/node_modules/' + pkg
    modules.push require path
  return modules[0] if specs.length is 1
  modules

module.exports = (args...) ->
  if args.length is 0 or typeof args[args.length - 1] isnt 'function'
    return sync args

  callback = args.pop()
  async args, callback
  null
