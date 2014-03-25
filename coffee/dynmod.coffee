
req = require './api/req'
module.exports         = req
module.exports.require = req
module.exports.install = require './api/install'
module.exports.bin     = require './api/bin'
module.exports.list    = require './api/list'
module.exports.current = require './api/current'
module.exports.remove  = require './api/remove'
