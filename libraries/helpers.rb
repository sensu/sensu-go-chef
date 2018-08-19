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
      spec['extended_attributes'] = new_resource.extended_attributes if new_resource.extended_attributes
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
      c['type'] = type_from_name
      c['spec'] = spec
      c
    end

    def asset_from_resource
      spec = {}
      spec['name'] = new_resource.name
      spec['metadata'] = new_resource.metadata if new_resource.metadata
      spec['organization'] = new_resource.organization if new_resource.organization
      spec['sha512'] = new_resource.sha512
      spec['url'] = new_resource.url

      a = {}
      a['type'] = type_from_name
      a['spec'] = spec
      a
    end

    def handler_from_resource
      spec = {}
      spec['name'] = new_resource.name
      spec['command'] = new_resource.command if new_resource.command
      spec['env_vars'] = new_resource.env_vars if new_resource.env_vars
      spec['environment'] = new_resource.environment
      spec['filters'] = new_resource.filters if new_resource.filters
      spec['handlers'] = new_resource.handlers if new_resource.handlers
      spec['mutator'] = new_resource.mutator if new_resource.mutator
      spec['organization'] = new_resource.organization
      spec['socket'] = new_resource.socket if new_resource.socket
      spec['timeout'] = new_resource.timeout if new_resource.timeout
      spec['type'] = new_resource.type

      h = {}
      h['type'] = type_from_name
      h['spec'] = spec
      h
    end

    def filter_from_resource
      spec = {}
      spec['name'] = new_resource.name
      spec['action'] = new_resource.filter_action
      spec['environment'] = new_resource.environment if new_resource.environment
      spec['organization'] = new_resource.organization if new_resource.organization
      spec['statements'] = new_resource.statements
      spec['when'] = new_resource.when if new_resource.when

      f = {}
      f['type'] = 'event_' + type_from_name
      f['spec'] = spec
      f
    end

    def mutator_from_resource
      spec = {}
      spec['name'] = new_resource.name
      spec['command'] = new_resource.command
      spec['env_vars'] = new_resource.env_vars if new_resource.env_vars
      spec['environment'] = new_resource.environment
      spec['organization'] = new_resource.organization if new_resource.organization
      spec['timeout'] = new_resource.timeout if new_resource.timeout

      m = {}
      m['type'] = type_from_name
      m['spec'] = spec
      m
    end

    def latest_version?(version)
      version == 'latest' || version == :latest
    end
  end
end
