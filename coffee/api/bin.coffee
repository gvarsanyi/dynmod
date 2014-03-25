fs = require 'fs'

dir     = require '../dir'
list    = require './list'
install = require './install'


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

    get_bins = ->
      path = dir + '/' + pkg + '/' + version + '/node_modules/.bin'
      fs.readdir path, (err, bins) ->
        return conclude(null, []) if err or not bins
        dict = {}
        dict[bin] = path + '/' + bin for bin in bins
        conclude null, dict

    [pkg, version] = spec.split '@'

    list pkg, (err, versions) ->
      if not version and versions and versions.length
        version = versions[versions.length - 1]
      unless version and version in versions
        install spec, (err, _version) ->
          return conclude(err) if err
          version = _version
          get_bins()
      else
        get_bins()

  read_spec(spec) for spec in specs

sync = (specs) ->
  throw new Error('A module name is required') unless specs.length
  modules = []

  for spec in specs
    [pkg, version] = spec.split '@'

    versions = list pkg
    if not version and versions and versions.length
      version = versions[versions.length - 1]
    install(spec) unless version and version in versions

    path = dir + '/' + pkg + '/' + version + '/node_modules/.bin'
    bins = []
    try
      bins = fs.readdirSync path
    dict = {}
    dict[bin] = path + '/' + bin for bin in bins
    modules.push dict

  return modules[0] if specs.length is 1
  modules

module.exports = (args...) ->
  if args.length is 0 or typeof args[args.length - 1] isnt 'function'
    return sync args

  callback = args.pop()
  async args, callback
  null
