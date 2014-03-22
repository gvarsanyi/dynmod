fs = require 'fs'

dir  = require './dir'
list = require './list'


module.exports = (callback) ->
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
        list pkg, (err, versions) ->
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
