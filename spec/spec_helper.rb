require 'chefspec'
require 'chefspec/berkshelf'

at_exit { ChefSpec::Coverage.report! }

log_level = :fatal
UBUNTU_OPTS = {
  platform: 'ubuntu',
  version: '16.04',
  log_level: log_level,
  file_cache_path: '/tmp',
}.freeze

WINDOWS_OPTS = {
  platform: 'windows',
  version: '2012R2',
  log_level: log_level,
  file_cache_path: 'c:\chef',
}.freeze
