#!/usr/bin/env coffee

child_process = require 'child_process'

dynmod = require './dynmod'


error = (err, no_usage) ->
  console.error ''

  if Array.isArray err
    console.error (String(e) for e in err).join '\n'
  else
    console.error String err

  unless no_usage
    console.error """

    Usage: (binary-name is required for packages with multiple binaries)
      dynomd-run package[@version][:binary-name] [parameters...]

    """

  process.exit 1


run = (bin) ->
  child = child_process.exec bin + ' ' + process.argv[3 ..].join ' '
  child.stderr.on 'data', (data) ->
    process.stderr.write data
  child.stdout.on 'data', (data) ->
    process.stdout.write data


unless process.argv[2]
  error new Error 'Missing package name'

args = process.argv[3 ...]
[spec, bin] = String(process.argv[2]).split ':'

dynmod.bin spec, (err, binaries) ->
  return error(err, true) if err
  bin_list = []
  bin_list.push(b) for b, path of binaries
  if not binaries or bin_list.length is 0
    error new Error 'No binaries available for ' + spec
  else if bin
    if binaries[bin]?
      run binaries[bin]
    else
      error new Error 'No such binary for ' + spec + ': ' + bin +
                      '. Available: ' + bin_list.join ', '
  else if bin_list.length is 1
    run binaries[bin_list[0]]
  else
    error new Error 'Multiple binaries are available for ' + spec + ': ' +
                    bin_list.join ', '
