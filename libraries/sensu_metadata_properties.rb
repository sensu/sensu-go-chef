module SensuCookbook
  module SensuMetadataProperties
  # lazy load the common properties for metadata
    def self.included(base)
      base.class_eval do
        property :namespace, String, default: 'default'
        property :labels, Hash
        property :annotations, Hash
      end
    end
  end
end
