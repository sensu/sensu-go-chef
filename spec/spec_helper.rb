require 'chefspec'
require 'chefspec/berkshelf'

require_relative 'support/platforms'

at_exit { ChefSpec::Coverage.report! }
