#!/usr/bin/env coffee

dynmod = require './dynmod'

error = (err) ->
  console.error String err
  process.exit 1

switch process.argv[2]
  when 'i', 'install'
    pkg = process.argv[3] or error new Error 'no module specified'
    dynmod.install pkg, (err) ->
      return error(err) if err
  when 'del', 'delete', 'rm', 'remove'
    pkg = process.argv[3] or error new Error 'no module specified'
    dynmod.remove pkg, (err) ->
      return error(err) if err
  when 'll', 'ls', 'list'
    if pkg = process.argv[3]
      dynmod.list pkg, (err, versions) ->
        return error(err) if err
        if pkg
          if not versions or (versions and not versions.length)
            return console.log pkg + ' is not installed'
          console.log pkg + ': ' + versions.join ', '
    else
      dynmod.listAll (err, versions) ->
        for pkg, ver of versions
          console.log pkg + ': ' + ver.join ', '
  when 'c', 'cur', 'curr', 'current'
    pkg = process.argv[3] or error new Error 'missing module'
    dynmod.current pkg, (err, version, installed, versions) ->
      return error(err) if err
      console.log 'Latest version of ' + pkg + ' in npm: ' + version
      if installed and versions and versions.length <= 1
        console.log '  - this is the only version installed locally'
      else if installed and versions and versions.length > 1
        console.log '  - installed locally'
        locals = (v for v in versions when v isnt version)
        console.log '  - also installed: ' + locals.join ', '
      else if versions and versions.length > 0
        console.log '  - this version is NOT installed locally'
        console.log '  - installed: ' + versions.join ', '
      else
        console.log '  - module is NOT installed locally'
  when 'test'
    pkg     = process.argv[3] or error new Error 'missing module'
    version = process.argv[4] or false
    dynmod pkg, (err, mod) ->
      return error(err) if err
      console.log mod
  else
    error new Error 'Invalid command. Usage:\n' +
                    '\ndynmod [command] module[@version]\n\n' +
                    'Commands: install (i), remove (rm, del, delete), list ' +
                    '(ls, ll)\n'
