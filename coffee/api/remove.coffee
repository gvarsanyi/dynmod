child_process = require 'child_process'
fs            = require 'fs'

dir = require './dir'


module.exports = (spec, callback) ->
  [pkg, version] = spec.split '@'

  console.log '[dynmod] removing ' + spec
  if version
    delete req.cache[pkg][version] if (req = require './req').cache[pkg]?
    rm_dir = dir + '/' + pkg + '/' + version
  else
    delete require('./req').cache[pkg]
    rm_dir = dir + '/' + pkg

  child_process.exec 'rm -rf ' + rm_dir, (err) ->
    return callback(err) if err
    return callback() unless version
    fs.readdir dir + '/' + pkg, (err, files) ->
      return callback() if err or (files and files.length)
      child_process.exec 'rm -rf ' + dir + '/' + pkg, (err) ->
        callback()
