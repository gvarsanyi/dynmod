// Generated by CoffeeScript 1.7.1
(function() {
  var home_folder_ref;

  home_folder_ref = process.platform === 'win32' ? 'USERPROFILE' : 'HOME';

  module.exports = process.env[home_folder_ref] + '/.dynmod';

}).call(this);
