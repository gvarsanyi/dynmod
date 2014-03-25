// Generated by CoffeeScript 1.7.1
(function() {
  var async, cache, child_process, dir, exec_sync, fs, sync,
    __slice = [].slice;

  child_process = require('child_process');

  exec_sync = require('sync-exec');

  fs = require('fs');

  cache = require('../cache');

  dir = require('../dir');

  async = function(specs, callback) {
    var count, errors, read_spec, spec, total, _i, _len, _results;
    if (!specs.length) {
      return callback(new Error('A module name is required'));
    }
    errors = [];
    count = 0;
    total = specs.length;
    read_spec = function(spec) {
      var conclude, pkg, rm_dir, version, _ref;
      conclude = function(err, mod) {
        count += 1;
        if (err) {
          errors.push(err);
        }
        if (count >= total) {
          if (errors.length === 1) {
            return callback(errors[0]);
          } else if (errors.length > 1) {
            return callback(errors);
          } else {
            return callback();
          }
        }
      };
      _ref = spec.split('@'), pkg = _ref[0], version = _ref[1];
      console.log('[dynmod] removing ' + spec);
      if (version) {
        if (cache.pkg[pkg] != null) {
          delete cache.pkg[pkg][version];
        }
        rm_dir = dir + '/' + pkg + '/' + version;
      } else {
        delete cache.pkg[pkg];
        rm_dir = dir + '/' + pkg;
      }
      return fs.exists(rm_dir, function(exists) {
        if (!exists) {
          return conclude(new Error(spec + ' is not installed'));
        }
        return child_process.exec('rm -rf ' + rm_dir, function(err) {
          if (err) {
            return conclude(err);
          }
          if (!version) {
            return conclude();
          }
          return fs.readdir(dir + '/' + pkg, function(err, files) {
            if (err || (files && files.length)) {
              return conclude();
            }
            return child_process.exec('rm -rf ' + dir + '/' + pkg, function(err) {
              return conclude();
            });
          });
        });
      });
    };
    _results = [];
    for (_i = 0, _len = specs.length; _i < _len; _i++) {
      spec = specs[_i];
      _results.push(read_spec(spec));
    }
    return _results;
  };

  sync = function(specs) {
    var files, pkg, rm_dir, spec, version, _i, _len, _ref;
    if (!specs.length) {
      throw new Error('A module name is required');
    }
    for (_i = 0, _len = specs.length; _i < _len; _i++) {
      spec = specs[_i];
      _ref = spec.split('@'), pkg = _ref[0], version = _ref[1];
      console.log('[dynmod] removing ' + spec);
      if (version) {
        if (cache.pkg[pkg] != null) {
          delete cache.pkg[pkg][version];
        }
        rm_dir = dir + '/' + pkg + '/' + version;
      } else {
        delete cache.pkg[pkg];
        rm_dir = dir + '/' + pkg;
      }
      if (!fs.existsSync(rm_dir)) {
        throw new Error(spec + ' is not installed');
      }
      exec_sync('rm -rf ' + rm_dir);
      if (!version) {
        return true;
      }
      files = fs.readdirSync(dir + '/' + pkg);
      if (!(files && files.length)) {
        exec_sync('rm -rf ' + dir + '/' + pkg);
      }
    }
    return true;
  };

  module.exports = function() {
    var args, callback;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (args.length === 0 || typeof args[args.length - 1] !== 'function') {
      return sync(args);
    }
    callback = args.pop();
    async(args, callback);
    return null;
  };

}).call(this);
