child_process = require 'child_process'
exec_sync     = require 'sync-exec'

list = require './list'


async = (pkgs, callback) ->
  return callback(new Error 'A module name is required') unless pkgs.length

  errors  = []
  modules = {}
  count   = 0
  total   = pkgs.length

  read_pkg = (pkg) ->
    modules[pkg] = null

    conclude = (err, mod) ->
      count += 1
      errors.push(err) if err
      modules[pkg] = mod

      if count >= total
        response = []
        response.push(mod) for pkg, mod of modules
        if errors.length is 1
          callback errors[0], response...
        else if errors.length > 1
          callback errors, response...
        else
          callback null, response...

    if pkg.indexOf('@') > -1
      return conclude new Error 'Version is not required'

    cmd = 'npm show ' + pkg + ' version 2> /dev/null'
    child_process.exec cmd, (err, stdout, stderr) ->
      return conclude(err) if err
      current = stdout.replace /^\s+|\s+$/g, '' # trim
      conclude null, current

  read_pkg(pkg) for pkg in pkgs

sync = (pkgs) ->
  throw new Error('A module name is required') unless pkgs.length
  modules = []

  for pkg in pkgs
    throw new Error('Version is not required') if pkg.indexOf('@') > -1

    {status, stdout, stderr} = exec_sync 'npm show ' + pkg + ' version'
    throw new Error(stderr) if status
    current  = stdout.replace /^\s+|\s+$/g, '' # trim
    modules.push current
  return modules[0] if pkgs.length is 1
  modules

module.exports = (args...) ->
  if args.length is 0 or typeof args[args.length - 1] isnt 'function'
    return sync args

  callback = args.pop()
  async args, callback
  null
