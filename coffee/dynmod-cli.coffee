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
  when 'bin', 'r', 'run'
    [spec, bin] = process.argv[3 .. 4]
    dynmod.bin spec, (err, binaries) ->
      return error(err) if err
      bin_list = []
      bin_list.push(b) for b, path of binaries
      if not binaries or bin_list.length is 0
        error new Error 'No binaries available for ' + spec
      else if bin
        if binaries[bin]?
          console.log binaries[bin]
        else
          error new Error 'No such binary for ' + spec + ': ' + bin +
                          '. Available: ' + bin_list.join ', '
      else if bin_list.length is 1
        console.log binaries[bin_list[0]]
      else
        error new Error 'Multiple binaries are available for ' + spec + ': ' +
                        bin_list.join ', '
  else
    msg = """
          Invalid command. Usage:

          dynmod install module[@version]
          dynmod remove module[@version]
          dynmod list module
          dynmod run module[@version] [binary-name]
          """
    error new Error msg
