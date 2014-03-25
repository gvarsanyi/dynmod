#!/usr/bin/env coffee

dynmod = require './dynmod'

error = (err) ->
  if Array.isArray err
    console.error (String(e) for e in err).join '\n'
  else
    console.error String err
  process.exit 1

switch process.argv[2]
  when 'i', 'install'
    pkgs = process.argv[3...]
    dynmod.install pkgs..., (err) ->
      return error(err) if err
  when 'del', 'delete', 'rm', 'remove'
    pkgs = process.argv[3...]
    dynmod.remove pkgs..., (err) ->
      return error(err) if err
  when 'll', 'ls', 'list'
    pkgs = process.argv[3...]
    dynmod.list pkgs..., (err, versions) ->
      console.log err, versions
      if versions
        if pkgs.length isnt 1
          console.log(pkg + ': ' + vers.join ', ') for pkg, vers of versions
        else
          console.log versions.join ', '
      error(err) if err
  when 'c', 'cur', 'curr', 'current'
    pkgs = process.argv[3...]
    dynmod.current pkgs..., (err, versions...) ->
      for pkg, i in pkgs
        console.log pkg + ': ' + (versions[i] or '-')
  else
    error new Error 'Invalid command. Usage:\n' +
                    '\ndynmod [command] module[@version]\n\n' +
                    'Commands: install (i), remove (rm, del, delete), list ' +
                    '(ls, ll)\n'
