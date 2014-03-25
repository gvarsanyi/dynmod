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
## Global install makes it available for all of your projects plus it makes the command line version available system wide. Requires administrator permissions (sudo).
    [sudo] npm install dynmod -g
## Local install
    npm install dynmod

# API
## Asynchronous
### require
#### Require module(s) - auto-install them as needed
#### A *spec* is a name of an npm package with optional version specificiation. E.g. 'express' or 'express@3.5.0'
    var dynmod = require('dynmod');
    // Asynchronous:
    dynmod.**require**('*spec*'[, '*spec2*', ...], function callback(err, module[, module2, ...]) {});
    // Synchronous:
    var module = dynmod.**require**('*spec*');
    var modules_array = dynmod.**require**('*spec1*'[, '*spec2*', ...]);
    // Will also work with just calling dynmod (e.g. not 'dynmod.require') :
    dynmod('*spec*', function callback(err, module) {}); // short asynchronous require
    var module = dynmod('*spec*'); // short synchronous require

### list
#### Get locally installed version(s) of a module(s)
#### A *package* is a name of an npm package. E.g. 'express'
    var dynmod = require('dynmod');
    // Asynchronous:
    dynmod.**list**('*package*', function callback(err, versions) {});
    dynmod.**list**(['*package1*', '*package2*'], function callback(err, versions_per_packages_dictionary) {});
    // Synchronous:
    var versions = dynmod.**list**('*package*');
    var versions_per_packages_dictionary = dynmod.**list**(['*package1*', '*package2*']);

### install
#### Install module(s) locally
#### A *spec* is a name of an npm package with optional version specificiation. E.g. 'express' or 'express@3.5.0'
    var dynmod = require('dynmod');
    // Asynchronous:
    dynmod.**install**('*spec*'[, '*spec2*', ...], function callback(err, version[, version2, ...]) {});
    // Synchronous:
    var version = dynmod.**install**('*spec*');
    var versions_array = dynmod.**install**('*spec1*', '*spec2*'[, ...]);

### remove
#### Remove locally installed modules
#### A *spec* is a name of an npm package with optional version specificiation. E.g. 'express' or 'express@3.5.0'
    var dynmod = require('dynmod');
    // Asynchronous:
    dynmod.**remove**('*spec*'[, '*spec2*', ...], function callback(err) {});
    // Synchronous:
    dynmod.**remove**('*spec*'[, '*spec2*', ...]);

## Command line examples
### Install
    dynmod install *spec* [*spec2* ...]

### Remove
    dynmod remove *spec* [*spec2* ...]

### List
    dynmod list [*package* *package2* ...]

### Run binary
    dynmod-run *spec* [binary-name]
