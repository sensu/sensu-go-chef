module SensuCookbook
  module SensuCommonProperties
    # lazy load the common properties
    def self.included(base)
      base.class_eval do
        property :config_home, String, default: '/etc/sensu'
      end
    end
  end
end
