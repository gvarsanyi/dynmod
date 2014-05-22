#!/usr/bin/env node
// Generated by CoffeeScript 1.7.1
(function() {
  var bin, dynmod, error, msg, pkgs, spec, _ref,
    __slice = [].slice;

  dynmod = require('./dynmod');

  error = function(err) {
    var e;
    if (Array.isArray(err)) {
      console.error(((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = err.length; _i < _len; _i++) {
          e = err[_i];
          _results.push(String(e));
        }
        return _results;
      })()).join('\n'));
    } else {
      console.error(String(err));
    }
    return process.exit(1);
  };

  switch (process.argv[2]) {
    case 'i':
    case 'install':
      pkgs = process.argv.slice(3);
      dynmod.install.apply(dynmod, __slice.call(pkgs).concat([function(err) {
        if (err) {
          return error(err);
        }
      }]));
      break;
    case 'del':
    case 'delete':
    case 'rm':
    case 'remove':
      pkgs = process.argv.slice(3);
      dynmod.remove.apply(dynmod, __slice.call(pkgs).concat([function(err) {
        if (err) {
          return error(err);
        }
      }]));
      break;
    case 'll':
    case 'ls':
    case 'list':
      pkgs = process.argv.slice(3);
      dynmod.list.apply(dynmod, __slice.call(pkgs).concat([function(err, versions) {
        var pkg, vers;
        if (versions) {
          if (pkgs.length !== 1) {
            for (pkg in versions) {
              vers = versions[pkg];
              console.log(pkg + ': ' + vers.join(', '));
            }
          } else {
            console.log(versions.join(', '));
          }
        }
        if (err) {
          return error(err);
        }
      }]));
      break;
    case 'c':
    case 'cur':
    case 'curr':
    case 'current':
      pkgs = process.argv.slice(3);
      dynmod.current.apply(dynmod, __slice.call(pkgs).concat([function() {
        var err, i, pkg, versions, _i, _len, _results;
        err = arguments[0], versions = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        _results = [];
        for (i = _i = 0, _len = pkgs.length; _i < _len; i = ++_i) {
          pkg = pkgs[i];
          _results.push(console.log(pkg + ': ' + (versions[i] || '-')));
        }
        return _results;
      }]));
      break;
    case 'bin':
    case 'r':
    case 'run':
      _ref = process.argv.slice(3, 5), spec = _ref[0], bin = _ref[1];
      dynmod.bin(spec, function(err, binaries) {
        var b, bin_list, path;
        if (err) {
          return error(err);
        }
        bin_list = [];
        for (b in binaries) {
          path = binaries[b];
          bin_list.push(b);
        }
        if (!binaries || bin_list.length === 0) {
          return error(new Error('No binaries available for ' + spec));
        } else if (bin) {
          if (binaries[bin] != null) {
            return console.log(binaries[bin]);
          } else {
            return error(new Error('No such binary for ' + spec + ': ' + bin + '. Available: ' + bin_list.join(', ')));
          }
        } else if (bin_list.length === 1) {
          return console.log(binaries[bin_list[0]]);
        } else {
          return error(new Error('Multiple binaries are available for ' + spec + ': ' + bin_list.join(', ')));
        }
      });
      break;
    default:
      msg = "Invalid command. Usage:\n\ndynmod install module[@version]\ndynmod remove module[@version]\ndynmod list module\ndynmod run module[@version] [binary-name]";
      error(new Error(msg));
  }

}).call(this);
