#!/usr/bin/env coffee

dynmod = require './dynmod'

error = (err) ->
  console.error String err
  process.exit 1

switch process.argv[2]
  when 'i', 'install'
    pkg     = process.argv[3] or error new Error 'missing module'
    version = process.argv[4] or false
    dynmod.install pkg, version, (err) ->
      return error(err) if err
  when 'del', 'delete', 'rm', 'remove'
    pkg     = process.argv[3] or error new Error 'missing module'
    version = process.argv[4] or error new Error 'missing version'
    dynmod.remove pkg, version, (err) ->
      return error(err) if err
  when 'll', 'ls', 'list'
    pkg = process.argv[3] or error new Error 'missing module'
    dynmod.installedVersions pkg, (err, versions) ->
      return error(err) if err
      if not versions or (versions and not versions.length)
        return console.log pkg + ' is not installed'
      console.log pkg + ': ' + versions.join ', '
  else
    error new Error 'Invalid command. Usage:\n' +
                    '\ndynmod [command] module [version]\n\n' +
                    'Commands: install (i), remove (rm, del, delete), list ' +
                    '(ls, ll)\n'