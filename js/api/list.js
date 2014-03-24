// Generated by CoffeeScript 1.7.1
(function() {
  var cache, current, dir, fs, list_all;

  fs = require('fs');

  cache = require('../cache');

  current = require('./current');

  dir = require('../dir');

  list_all = require('./list-all');

  module.exports = function(pkg, callback) {
    if (typeof pkg === 'function') {
      return list_all(pkg);
    }
    if (!pkg) {
      return list_all(callback);
    }
    if (pkg.indexOf('@') > -1) {
      return callback(new Error('Version is not required'));
    }
    return fs.exists(dir + '/' + pkg, function(exists) {
      if (!exists) {
        return callback(null, false);
      }
      return fs.readdir(dir + '/' + pkg, function(err, versions) {
        delete cache.current[pkg];
        if (!versions.length) {
          return callback(null, false);
        }
        if (versions && versions.length) {
          cache.current[pkg] = versions[versions.length - 1];
        }
        return callback(null, versions);
      });
    });
  };

  module.exports.sync = function(pkg) {
    var versions;
    if (!pkg) {
      return list_all.sync();
    }
    if (pkg.indexOf('@') > -1) {
      throw new Error('Version is not required');
    }
    if (!fs.existsSync(dir + '/' + pkg)) {
      return false;
    }
    versions = fs.readdirSync(dir + '/' + pkg);
    if (versions && versions.length) {
      cache.current[pkg] = versions[versions.length - 1];
    }
    return versions;
  };

}).call(this);
