dynmod
=======

Enables asynchronous loading (with auto-installing as needed) npm module packages.
Stores npm packages per user (no need for sudo rights) but still makes packages available system-wide.
Handles multiple versions of npm packages, so despite being system-wide, so your projects can still link different versions.

# Why?
- Asynchronous require rocks
- Not everyone likes to check out all the npm packages in all the project directories (time, disk space etc)
- Allows your project to install dependencies only when it wants to use them.

# Install
## Global install makes it available for all of your projects plus it makes the command line version available system wide. Requires administrator permissions (sudo).
    npm install dynmod -g
## Local install
    npm install dynmod

# API
- require('dynmod').**require**(npm_module_name[, version], function callback(err, module) {});
- require('dynmod').**remove**(npm_module_name, version, function callback(err) {});
- require('dynmod').**list**(npm_module_name, function callback(err, versions) {});

# Examples
## Code requires latest (or most current locally installed version) of ExpressJS
    var dynmod = require('dynmod');
    dynmod.require('express', function (err, express) {
      var app = express();
      // ... my express app logic
    });

## Code requires a specific version of ExpressJS
    var dynmod = require('dynmod');
    dynmod.require('express', '3.5.0', function (err, express) {
      var app = express();
      // ... my express app logic
    });

## Command line examples
### Install latest version of express
    dynmod install express

### Install a specific version of express
    dynmod install express 3.5.0

### Remove an installed version of express
    dynmod remove express 3.5.0

### List installed versions of express
    dynmod list express
