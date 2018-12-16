module SensuCookbook
  module SensuPackageProperties
    # lazy load the common properties for package resources
    def self.included(base)
      base.class_eval do
        property :version, String, default: 'latest'
        property :repo, String, default: 'sensu/beta'
      end
    end
  end
end
