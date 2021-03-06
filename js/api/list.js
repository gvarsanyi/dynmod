// Generated by CoffeeScript 1.7.1
(function() {
  var async, cache, dir, fs, sync,
    __slice = [].slice;

  fs = require('fs');

  cache = require('../cache');

  dir = require('../dir');

  async = function(pkgs, callback) {
    var dict, read_pkgs;
    dict = {};
    read_pkgs = function() {
      var count, errors, pkg, read_pkg, total, _i, _len, _results;
      errors = [];
      count = 0;
      total = pkgs.length;
      read_pkg = function(pkg) {
        var conclude;
        conclude = function() {
          count += 1;
          if (count >= total) {
            if (pkgs.length === 1) {
              dict = dict[pkgs[0]];
            }
            if (errors.length === 1) {
              return callback(errors[0], dict);
            } else if (errors.length > 1) {
              return callback(errors, dict);
            } else {
              return callback(null, dict);
            }
          }
        };
        if (pkg.indexOf('@') > -1) {
          errors.push(new Error('Version is not required'));
        }
        return fs.exists(dir + '/' + pkg, function(exists) {
          if (!exists) {
            delete cache.current[pkg];
            delete dict[pkg];
            errors.push(new Error('Package is not installed: ' + pkg));
            return conclude();
          }
          return fs.readdir(dir + '/' + pkg, function(err, versions) {
            if (!(versions && versions.length)) {
              delete cache.current[pkg];
              delete dict[pkg];
            } else {
              cache.current[pkg] = versions[versions.length - 1];
              dict[pkg] = versions;
            }
            return conclude();
          });
        });
      };
      _results = [];
      for (_i = 0, _len = pkgs.length; _i < _len; _i++) {
        pkg = pkgs[_i];
        _results.push(read_pkg(pkg));
      }
      return _results;
    };
    if (pkgs.length) {
      return read_pkgs();
    }
    return fs.readdir(dir, function(err, _pkgs) {
      if (err || !_pkgs.length) {
        return callback(err, dict);
      }
      pkgs = _pkgs;
      return read_pkgs();
    });
  };

  sync = function(pkgs) {
    var dict, err, pkg, versions, _i, _len;
    dict = {};
    if (!pkgs.length) {
      pkgs = fs.readdirSync(dir);
    }
    for (_i = 0, _len = pkgs.length; _i < _len; _i++) {
      pkg = pkgs[_i];
      if (pkg.indexOf('@') > -1) {
        throw new Error('Version is not required');
      }
      if (!fs.existsSync(dir + '/' + pkg)) {
        return false;
      }
      try {
        versions = fs.readdirSync(dir + '/' + pkg);
      } catch (_error) {
        err = _error;
        delete cache.current[pkg];
        throw err;
      }
      if (versions && versions.length) {
        cache.current[pkg] = versions[versions.length - 1];
      }
      dict[pkg] = versions;
    }
    if (pkgs.length === 1) {
      return dict[pkgs[0]];
    }
    return dict;
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
