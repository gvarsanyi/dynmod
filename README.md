dynmod
=======

Auto-installs npm (node module package) dependencies as needed.

Works both synchronous and asynchronous.

Stores npm packages per user (no need for sudo rights) but still makes packages available system-wide.

Handles multiple versions of npm packages, so despite being system-wide, so your projects can still link different versions.

# Why?
- Asynchronous require rocks
- Not everyone likes to check out all the npm packages in all the project directories (time, disk space etc)
- Allows your project to install dependencies only when they actually use them.

# Install
## Global install makes it available for all of your projects plus it makes the command line version available system-wide
### Requires administrator permissions (sudo)
    [sudo] npm install dynmod -g
## Local install
    npm install dynmod

# API
## Asynchronous
### require
#### Require module(s) - auto-install them as needed
    var dynmod = require('dynmod');
    // Asynchronous:
    dynmod.require('package[@version]'[, 'package[@version]', ...], function callback(err, module[, module, ...]) {});
    // Synchronous:
    var module = dynmod.require('package[@version]');
    var modules_array = dynmod.require('package[@version]'[, 'package[@version]', ...]);
    // Will also work with just calling dynmod (e.g. not 'dynmod.require') :
    dynmod('package[@version]', function callback(err, module) {}); // short asynchronous require
    var module = dynmod('package[@version]'); // short synchronous require

### list
#### Get locally installed version(s) of a module(s)
    var dynmod = require('dynmod');
    // Asynchronous:
    dynmod.list('package', function callback(err, versions) {});
    dynmod.list(['package', 'package', ...], function callback(err, versions_per_packages_dictionary) {});
    // Synchronous:
    var versions = dynmod.list('package');
    var versions_per_packages_dictionary = dynmod.list(['package', 'package', ...]);

### install
#### Install module(s) locally
    var dynmod = require('dynmod');
    // Asynchronous:
    dynmod.install('package[@version]'[, 'package[@version]', ...], function callback(err, version[, version, ...]) {});
    // Synchronous:
    var version = dynmod.install('package[@version]');
    var versions_array = dynmod.install('package[@version]', 'package[@version]'[, ...]);

### remove
#### Remove locally installed modules
    var dynmod = require('dynmod');
    // Asynchronous:
    dynmod.remove('package[@version]'[, 'package[@version]', ...], function callback(err) {});
    // Synchronous:
    dynmod.remove('package[@version]'[, 'package[@version]', ...]);

## Command line examples
### Install
    dynmod install package[@version] [package[@version] ...]

### Remove
    dynmod remove package[@version] [package[@version] ...]

### List
    dynmod list [package package ...]

### Run binary
    dynmod-run package[@version] [binary-name]
