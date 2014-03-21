child_process = require 'child_process'
fs            = require 'fs'

home_folder_ref = if process.platform is 'win32' then 'USERPROFILE' else 'HOME'
dir = process.env[home_folder_ref] + '/.dynmod'


trim = (str) ->
  str.replace /^\s+|\s+$/g, ''

read = (pkg, version, callback) ->
  try
    path = dir + '/' + pkg + '/' + version + '/node_modules/' + pkg
    callback null, require path
  catch err
    callback err

module.exports.require = (pkg, version, callback) ->
  if typeof version is 'function'
    callback = version
    version = false

  fallback = ->
    module.exports.installedVersions pkg, (err, versions) ->
      if versions and versions.length and version is false
        version = versions[versions.length - 1]
      if versions and versions.length and version in versions
        return read pkg, version, callback
      module.exports.install pkg, version, (err, version) ->
        if err or not version
          return callback err or new Error 'Error installing ' + pkg
        read pkg, version, callback

  if version
    fs.exists dir + '/' + pkg + '/' + version + '/.dynmod-proper', (e) ->
      return read(pkg, version, callback) if e
      fs.exists dir + '/' + pkg + '/' + version, (exists) ->
        if exists
          return callback new Error pkg + '@' + version + ' is partially ' +
                                    'installed (possibly being installed by ' +
                                    'an other process?). If you are sure this' +
                                    ' is a failed installation, use require(' +
                                    '\'dynmod\').remove(\'' + pkg + '\', \'' +
                                    version + '\'); to remove it.'
        fallback()
  else
    fallback()

module.exports.remove = (pkg, version, callback) ->
  return callback(new Error 'version is required to remove') unless version
  console.log '[dynmod] removing ' + pkg + '@' + version
  pkg_dir = dir + '/' + pkg
  child_process.exec 'rm -rf ' + pkg_dir + '/' + version, (err) ->
    return callback(err) if err
    fs.readdir pkg_dir, (err, files) ->
      return callback() if err or (files and files.length)
      child_process.exec 'rm -rf ' + pkg_dir, (err) ->
        callback()

module.exports.markAsProper = (pkg, version, callback) ->
  path = dir + '/' + pkg + '/' + version + '/.dynmod-proper'
  fs.writeFile path, '1', callback

module.exports.install = (pkg, version, callback) ->
  install = ->
    module.exports.installedVersions pkg, (err, versions) ->
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
          module.exports.markAsProper pkg, version, (err) ->
            return callback(err) if err
            console.log '[dynmod] installed ' + pkg + '@' + version
            callback null, version

  if typeof version is 'function'
    callback = version
    version = false

  return install() if version
  module.exports.latestVersion pkg, (err, latest_version) ->
    return callback(err) if err
    version = latest_version
    install()

module.exports.installedVersions = (pkg, callback) ->
  fs.exists dir + '/' + pkg, (exists) ->
    return callback(null, false) unless exists
    fs.readdir dir + '/' + pkg, (err, versions) ->
      return callback(null, false) unless versions.length
      callback null, versions

module.exports.latestVersion = (pkg, callback) ->
  cmd = 'npm show ' + pkg + ' version 2> /dev/null'
  child_process.exec cmd, (err, stdout, stderr) ->
    return callback(err) if err
    latest_version = trim stdout
    module.exports.installedVersions pkg, (err, versions) ->
      callback null, latest_version, versions and latest_version in versions
