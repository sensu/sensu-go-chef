module SensuCookbook
  module Helpers
    # Extract object type from resource type
    def type_from_name
      new_resource.declared_type.to_s.split('_').last
    end

    # Pluralize object directory name
    def object_dir
      ::File.join(new_resource.config_home, type_from_name) + 's'
    end

    def object_file
      ::File.join(object_dir, new_resource.name) + '.json'
    end

    # Get check properties from the resource
    # https://docs.sensu.io/sensu-core/2.0/reference/checks/#check-attributes
    def check_from_resource
      spec = {}
      spec['check_hooks'] = new_resource.check_hooks if new_resource.check_hooks
      spec['command'] = new_resource.command
      spec['cron'] = new_resource.cron
      spec['environment'] = new_resource.environment
      spec['handlers'] = new_resource.handlers
      spec['high_flap_threshold'] = new_resource.high_flap_threshold if new_resource.high_flap_threshold
      spec['interval'] = new_resource.interval if new_resource.interval
      spec['low_flap_threshold'] = new_resource.low_flap_threshold if new_resource.low_flap_threshold
      spec['name'] = new_resource.name
      spec['organization'] = new_resource.organization
      spec['proxy_entity_id'] = new_resource.proxy_entity_id if new_resource.proxy_entity_id
      spec['proxy_requests'] = new_resource.proxy_requests if new_resource.proxy_requests
      spec['publish'] = new_resource.publish if new_resource.publish
      spec['round_robin'] = new_resource.round_robin if new_resource.round_robin
      spec['runtime_assets'] = new_resource.runtime_assets if new_resource.runtime_assets
      spec['stdin'] = new_resource.stdin
      spec['subdue'] = new_resource.subdue if new_resource.subdue
      spec['subscriptions'] = new_resource.subscriptions
      spec['timeout'] = new_resource.timeout if new_resource.timeout
      spec['ttl'] = new_resource.ttl if new_resource.ttl

      c = {}
      c['type'] = type_from_name.capitalize
      c['spec'] = spec
      c
    end

    def asset_from_resource
      a = {}
      a['name'] = new_resource.name
      a['metadata'] = new_resource.metadata if new_resource.metadata
      a['organization'] = new_resource.organization if new_resource.organization
      a['sha512'] = new_resource.sha512
      a['url'] = new_resource.url
    end
  end
end
