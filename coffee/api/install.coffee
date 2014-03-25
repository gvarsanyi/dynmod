child_process = require 'child_process'
exec_sync     = require 'sync-exec'
fs            = require 'fs'

cache   = require '../cache'
current = require './current'
dir     = require '../dir'
list    = require './list'
remove  = require './remove'


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

    install = ->
      list pkg, (err, versions) ->
        return conclude(err) if err
        if versions and versions.length and version in versions
          msg = pkg + '@' + version + ' is already installed'
          return conclude new Error(msg), version
        pkg_dir = dir + '/' + pkg + '/' + version
        child_process.exec 'mkdir -p ' + pkg_dir, (err) ->
          return conclude(err) if err
          console.log '[dynmod] attempting to install ' + pkg + '@' + version
          cmd = 'npm install ' + pkg + '@' + version + ' 2>1 | grep -v ' +
                '"npm http "'
          child_process.exec cmd, cwd: pkg_dir, (err, stdout) ->
            if err
              console.log '[dynmod] failed to install ' + pkg + '@' + version +
                          ' -- cleaning up'
              return remove spec, ->
                conclude err
            path = dir + '/' + pkg + '/' + version + '/.dynmod-proper'
            fs.writeFile path, '1', (err) ->
              return conclude(err) if err
              delete cache.current[pkg]
              console.log '[dynmod] installed ' + pkg + '@' + version
              conclude null, version

    return install() if version
    current pkg, (err, latest_version) ->
      return callback(err) if err
      version = latest_version
      install()

  read_spec(spec) for spec in specs

sync = (specs) ->
  throw new Error('A module name is required') unless specs.length
  modules = []

  for spec in specs
    [pkg, version] = spec.split '@'

    version = current(pkg) unless version

    versions = list pkg
    if versions and versions.length and version in versions
      throw new Error pkg + '@' + version + ' is already installed'

    pkg_dir = dir + '/' + pkg + '/' + version
    console.log '[dynmod] attempting to install ' + pkg + '@' + version
    {status, stdout, stderr} = exec_sync 'mkdir -p ' + pkg_dir
    throw new Error(stderr) if status

    cmd = 'cd ' + pkg_dir + '; npm install ' + pkg + '@' + version + ' 2>1 ' +
          '| grep -v "npm http "'
    {status, stdout, stderr} = exec_sync cmd
    try
      throw new Error(stderr) if status
      path = dir + '/' + pkg + '/' + version + '/.dynmod-proper'
      fs.writeFileSync path, '1'
    catch err
      console.log '[dynmod] failed to install ' + pkg + '@' + version +
                  ' -- cleaning up'
      remove.sync spec
      throw new Error err

    delete cache.current[pkg]
    console.log '[dynmod] installed ' + pkg + '@' + version
    modules.push version

  return modules[0] if specs.length is 1
  modules

module.exports = (args...) ->
  if args.length is 0 or typeof args[args.length - 1] isnt 'function'
    return sync args

  callback = args.pop()
  async args, callback
  null
