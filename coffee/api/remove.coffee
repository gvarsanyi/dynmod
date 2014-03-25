child_process = require 'child_process'
exec_sync     = require 'sync-exec'
fs            = require 'fs'

cache = require '../cache'
dir   = require '../dir'


async = (specs, callback) ->
  return callback(new Error 'A module name is required') unless specs.length

  errors = []
  count  = 0
  total  = specs.length

  read_spec = (spec) ->
    conclude = (err, mod) ->
      count += 1
      errors.push(err) if err

      if count >= total
        if errors.length is 1
          callback errors[0]
        else if errors.length > 1
          callback errors
        else
          callback()

    [pkg, version] = spec.split '@'

    console.log '[dynmod] removing ' + spec
    if version
      delete cache.pkg[pkg][version] if cache.pkg[pkg]?
      rm_dir = dir + '/' + pkg + '/' + version
    else
      delete cache.pkg[pkg]
      rm_dir = dir + '/' + pkg

    fs.exists rm_dir, (exists) ->
      return conclude(new Error spec + ' is not installed') unless exists
      child_process.exec 'rm -rf ' + rm_dir, (err) ->
        return conclude(err) if err
        return conclude() unless version
        fs.readdir dir + '/' + pkg, (err, files) ->
          return conclude() if err or (files and files.length)
          child_process.exec 'rm -rf ' + dir + '/' + pkg, (err) ->
            conclude()

  read_spec(spec) for spec in specs

sync = (specs) ->
  throw new Error('A module name is required') unless specs.length

  for spec in specs
    [pkg, version] = spec.split '@'

    console.log '[dynmod] removing ' + spec
    if version
      delete cache.pkg[pkg][version] if cache.pkg[pkg]?
      rm_dir = dir + '/' + pkg + '/' + version
    else
      delete cache.pkg[pkg]
      rm_dir = dir + '/' + pkg

    throw new Error(spec + ' is not installed') unless fs.existsSync rm_dir

    exec_sync 'rm -rf ' + rm_dir
    return true unless version

    files = fs.readdirSync dir + '/' + pkg
    unless files and files.length
      exec_sync 'rm -rf ' + dir + '/' + pkg
  true

module.exports = (args...) ->
  if args.length is 0 or typeof args[args.length - 1] isnt 'function'
    return sync args

  callback = args.pop()
  async args, callback
  null
