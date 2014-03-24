
home_folder_ref = if process.platform is 'win32' then 'USERPROFILE' else 'HOME'

module.exports = process.env[home_folder_ref] + '/.dynmod'
