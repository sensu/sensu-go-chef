module SensuCookbook
  module SensuCommonProperties
    # lazy load the common properties
    def self.included(base)
      base.class_eval do
        property :config_home, String, default: '/etc/sensu' if node['platform'] != 'windows'
        property :config_home, String, default: 'c:/ProgramData/Sensu/config' if node['platform'] == 'windows'
      end
    end
  end
end
