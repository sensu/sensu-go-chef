require 'chefspec'
require 'chefspec/berkshelf'

require_relative 'support/platforms'

# TODO: Cookstyle error: ChefDeprecations/ChefSpecCoverageReport: Don't use the deprecated ChefSpec coverage report functionality in your specs.
# at_exit { ChefSpec::Coverage.report! }
