child_process = require 'child_process'
fs            = require 'fs'

home_folder_ref = if process.platform is 'win32' then 'USERPROFILE' else 'HOME'
dir = process.env[home_folder_ref] + '/.dynmod'

cache = {}
most_vurrent_installed_versions = {}


read = (pkg, version, callback) ->
  try
    path = dir + '/' + pkg + '/' + version + '/node_modules/' + pkg
    mod = require path
    (cache[pkg] ?= {})[version] = mod
    callback null, mod
  catch err
    callback err

module.exports.require = module.exports = (pkg, version, callback) ->
  if typeof version is 'function'
    callback = version
    version = false

  if mod = cache[pkg]?[version or most_vurrent_installed_versions[pkg]]?
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
    module.exports.list pkg, (err, versions) ->
      return callback(err) if err
      if versions and versions.length > 0
        version = versions.pop()
        verify_version()
      else
        module.exports.install pkg, (err, version) ->
          return callback(err) if err
          version = versions.pop()
          verify_version()
  else
    verify_version()


module.exports.remove = (pkg, version, callback) ->
  return callback(new Error 'version is required to remove') unless version
  console.log '[dynmod] removing ' + pkg + '@' + version
  delete cache[pkg][version] if cache[pkg]?
  pkg_dir = dir + '/' + pkg
  child_process.exec 'rm -rf ' + pkg_dir + '/' + version, (err) ->
    return callback(err) if err
    fs.readdir pkg_dir, (err, files) ->
      return callback() if err or (files and files.length)
      child_process.exec 'rm -rf ' + pkg_dir, (err) ->
        callback()

module.exports.install = (pkg, version, callback) ->
  install = ->
    module.exports.list pkg, (err, versions) ->
      return callback(err) if err
      if versions and versions.length and version in versions
        return callback new Error pkg + '@' + version + ' is already installed'
      pkg_dir = dir + '/' + pkg + '/' + version
      child_process.exec 'mkdir -p ' + pkg_dir, (err) ->
        return callback(err) if err
        console.log '[dynmod] attempting to install ' + pkg + '@' + version
        cm = 'npm install ' + pkg + '@' + version + ' 2>1 | grep -v "npm http "'
        child_process.exec cm, cwd: pkg_dir, (err, stdout) ->
          if err
            return module.exports.remove pkg, version, ->
              callback err
          path = dir + '/' + pkg + '/' + version + '/.dynmod-proper'
          fs.writeFile path, '1', (err) ->
            return callback(err) if err
            delete most_vurrent_installed_versions[pkg]
            console.log '[dynmod] installed ' + pkg + '@' + version
            callback null, version

  if typeof version is 'function'
    callback = version
    version = false

  return install() if version
  module.exports.current pkg, (err, latest_version) ->
    return callback(err) if err
    version = latest_version
    install()

list_all = (callback) ->
  errors = []
  count = 0
  total = null
  dict  = {}

  fs.readdir dir, (err, pkgs) ->
    return callback(err, {}) if err or not pkgs.length
    total = pkgs.length
    dict[pkg] = null for pkg in pkgs
    for pkg in pkgs
      do (pkg) ->
        module.exports.list pkg, (err, versions) ->
          if err
            errors.push err
            delete dict[pkg]
          else unless versions and versions.length
            delete dict[pkg]
          else
            dict[pkg] = versions
          count += 1
          if count is total
            return callback(errors) if errors.length
            callback null, dict

module.exports.list = (pkg, callback) ->
  return list_all(pkg) if typeof pkg is 'function'
  return list_all(callback) unless pkg

  fs.exists dir + '/' + pkg, (exists) ->
    return callback(null, false) unless exists
    fs.readdir dir + '/' + pkg, (err, versions) ->
      delete most_vurrent_installed_versions[pkg]
      return callback(null, false) unless versions.length
      if versions and versions.length
        most_vurrent_installed_versions[pkg] = versions[versions.length - 1]
      callback null, versions

module.exports.current = (pkg, callback) ->
  cmd = 'npm show ' + pkg + ' version 2> /dev/null'
  child_process.exec cmd, (err, stdout, stderr) ->
    return callback(err) if err
    current = stdout.replace /^\s+|\s+$/g, '' # trim
    module.exports.list pkg, (err, versions) ->
      callback null, current, versions and current in versions, versions
