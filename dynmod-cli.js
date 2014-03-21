#!/usr/bin/env node

(function() {
  var dynmod, error, pkg, version;

  dynmod = require('./dynmod');

  error = function(err) {
    console.error(String(err));
    return process.exit(1);
  };

  switch (process.argv[2]) {
    case 'i':
    case 'install':
      pkg = process.argv[3] || error(new Error('missing module'));
      version = process.argv[4] || false;
      dynmod.install(pkg, version, function(err) {
        if (err) {
          return error(err);
        }
      });
      break;
    case 'del':
    case 'delete':
    case 'rm':
    case 'remove':
      pkg = process.argv[3] || error(new Error('missing module'));
      version = process.argv[4] || error(new Error('missing version'));
      dynmod.remove(pkg, version, function(err) {
        if (err) {
          return error(err);
        }
      });
      break;
    case 'll':
    case 'ls':
    case 'list':
      pkg = process.argv[3] || error(new Error('missing module'));
      dynmod.installedVersions(pkg, function(err, versions) {
        if (err) {
          return error(err);
        }
        if (!versions || (versions && !versions.length)) {
          return console.log(pkg + ' is not installed');
        }
        return console.log(pkg + ': ' + versions.join(', '));
      });
      break;
    default:
      error(new Error('Invalid command. Usage:\n' + '\ndynmod [command] module [version]\n\n' + 'Commands: install (i), remove (rm, del, delete), list ' + '(ls, ll)\n'));
  }

}).call(this);
