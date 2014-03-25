fs = require 'fs'

cache = require '../cache'
dir   = require '../dir'


async = (pkgs, callback) ->
  dict = {}

  read_pkgs = ->
    errors = []
    count = 0
    total = pkgs.length

    read_pkg = (pkg) ->
      conclude = ->
        count += 1
        if count >= total
          dict = dict[pkgs[0]] if pkgs.length is 1

          if errors.length is 1
            callback errors[0], dict
          else if errors.length > 1
            callback errors, dict
          else
            callback null, dict

      if pkg.indexOf('@') > -1
        errors.push new Error 'Version is not required'

      fs.exists dir + '/' + pkg, (exists) ->
        unless exists
          delete cache.current[pkg]
          delete dict[pkg]
          errors.push new Error 'Package is not installed: ' + pkg
          return conclude()
        fs.readdir dir + '/' + pkg, (err, versions) ->
          unless versions and versions.length
            delete cache.current[pkg]
            delete dict[pkg]
          else
            cache.current[pkg] = versions[versions.length - 1]
            dict[pkg] = versions
          conclude()

    read_pkg(pkg) for pkg in pkgs

  return read_pkgs() if pkgs.length
  fs.readdir dir, (err, _pkgs) ->
    return callback(err, dict) if err or not _pkgs.length
    pkgs = _pkgs
    read_pkgs()

sync = (pkgs) ->
  dict = {}
  pkgs = fs.readdirSync(dir) unless pkgs.length
  for pkg in pkgs
    throw new Error('Version is not required') if pkg.indexOf('@') > -1
    return false unless fs.existsSync dir + '/' + pkg
    try
      versions = fs.readdirSync dir + '/' + pkg
    catch err
      delete cache.current[pkg]
      throw err
    if versions and versions.length
      cache.current[pkg] = versions[versions.length - 1]
    dict[pkg] = versions
  return dict[pkgs[0]] if pkgs.length is 1
  dict

module.exports = (args...) ->
  if args.length is 0 or typeof args[args.length - 1] isnt 'function'
    return sync args

  callback = args.pop()
  async args, callback
  null