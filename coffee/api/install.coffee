child_process = require 'child_process'
fs            = require 'fs'

current = require './current'
dir     = require './dir'
list    = require './list'
remove  = require './remove'


module.exports = (spec, callback) ->
  [pkg, version] = spec.split '@'

  install = ->
    list pkg, (err, versions) ->
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
            return remove spec, ->
              callback err
          path = dir + '/' + pkg + '/' + version + '/.dynmod-proper'
          fs.writeFile path, '1', (err) ->
            return callback(err) if err
            delete current.cache[pkg]
            console.log '[dynmod] installed ' + pkg + '@' + version
            callback null, version

  return install() if version
  current pkg, (err, latest_version) ->
    return callback(err) if err
    version = latest_version
    install()

module.exports.sync = (spec) ->
