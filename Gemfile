source 'https://rubygems.org'

gem 'berkshelf'
gem 'chef-sugar'

group :development do
  gem 'foodcritic'
  gem 'chefspec'
  gem 'cookstyle', '~> 4.0'
  gem 'guard'
  gem 'guard-foodcritic'
  gem 'guard-rubocop'
  gem 'guard-rspec'
  gem 'kitchen-inspec'
  gem 'kitchen-dokken', '~> 2.6'
  gem 'kitchen-vagrant', '~> 1.3'
  gem 'test-kitchen'
  gem 'rb-readline' if Gem.win_platform?
  gem 'wdm', '>= 0.1.0' if Gem.win_platform?
  gem 'win32console' if Gem.win_platform?

  # the following gems are needed if you use ssh-ed25519 keys
  gem 'rbnacl', ['>= 3.2', '< 5.0'] unless ENV['TRAVIS']
  gem 'rbnacl-libsodium' unless ENV['TRAVIS']
  gem 'bcrypt_pbkdf', ['>= 1.0', '< 2.0'] unless ENV['TRAVIS']
end
