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
      spec['metadata'] = {}
      spec['metadata']['name'] = new_resource.name
      spec['metadata']['namespace'] = new_resource.namespace
      spec['metadata']['labels'] = new_resource.labels if new_resource.labels
      spec['metadata']['annotations'] = new_resource.annotations if new_resource.annotations
      spec['handlers'] = new_resource.handlers
      spec['high_flap_threshold'] = new_resource.high_flap_threshold if new_resource.high_flap_threshold
      spec['interval'] = new_resource.interval if new_resource.interval
      spec['low_flap_threshold'] = new_resource.low_flap_threshold if new_resource.low_flap_threshold
      spec['proxy_entity_name'] = new_resource.proxy_entity_name if new_resource.proxy_entity_name
      spec['proxy_requests'] = new_resource.proxy_requests if new_resource.proxy_requests
      spec['publish'] = new_resource.publish if new_resource.publish
      spec['round_robin'] = new_resource.round_robin if new_resource.round_robin
      spec['runtime_assets'] = new_resource.runtime_assets if new_resource.runtime_assets
      spec['stdin'] = new_resource.stdin
      spec['subdue'] = new_resource.subdue if new_resource.subdue
      spec['subscriptions'] = new_resource.subscriptions
      spec['timeout'] = new_resource.timeout if new_resource.timeout
      spec['ttl'] = new_resource.ttl if new_resource.ttl
      spec['output_metric_format'] = new_resource.output_metric_format if new_resource.output_metric_format
      spec['output_metric_handlers'] = new_resource.output_metric_handlers if new_resource.output_metric_handlers

      c = {}
      c['type'] = type_from_name
      c['spec'] = spec
      c
    end

    def asset_from_resource
      spec = {}
      spec['metadata'] = {}
      spec['metadata']['name'] = new_resource.name
      spec['metadata']['namespace'] = new_resource.namespace
      spec['metadata']['labels'] = new_resource.labels if new_resource.labels
      spec['metadata']['annotations'] = new_resource.annotations if new_resource.annotations
      spec['sha512'] = new_resource.sha512
      spec['url'] = new_resource.url

      a = {}
      a['type'] = type_from_name
      a['spec'] = spec
      a
    end

    def handler_from_resource
      spec = {}
      spec['command'] = new_resource.command if new_resource.command
      spec['env_vars'] = new_resource.env_vars if new_resource.env_vars
      spec['metadata'] = {}
      spec['metadata']['name'] = new_resource.name
      spec['metadata']['namespace'] = new_resource.namespace
      spec['metadata']['labels'] = new_resource.labels if new_resource.labels
      spec['metadata']['annotations'] = new_resource.annotations if new_resource.annotations
      spec['filters'] = new_resource.filters if new_resource.filters
      spec['handlers'] = new_resource.handlers if new_resource.handlers
      spec['mutator'] = new_resource.mutator if new_resource.mutator
      spec['runtime_assets'] = new_resource.runtime_assets if new_resource.runtime_assets
      spec['socket'] = new_resource.socket if new_resource.socket
      spec['timeout'] = new_resource.timeout if new_resource.timeout
      spec['type'] = new_resource.type

      h = {}
      h['type'] = type_from_name
      h['spec'] = spec
      h
    end

    def hook_from_resource
      spec = {}
      spec['command'] = new_resource.command if new_resource.command
      spec['timeout'] = new_resource.timeout if new_resource.timeout
      spec['stdin'] = new_resource.stdin if new_resource.stdin
      spec['metadata'] = {}
      spec['metadata']['name'] = new_resource.name
      spec['metadata']['namespace'] = new_resource.namespace
      spec['metadata']['labels'] = new_resource.labels if new_resource.labels
      spec['metadata']['annotations'] = new_resource.annotations if new_resource.annotations

      h = {}
      h['type'] = type_from_name
      h['spec'] = spec
      h
    end

    def filter_from_resource
      spec = {}
      spec['action'] = new_resource.filter_action
      spec['metadata'] = {}
      spec['metadata']['name'] = new_resource.name
      spec['metadata']['namespace'] = new_resource.namespace
      spec['metadata']['labels'] = new_resource.labels if new_resource.labels
      spec['metadata']['annotations'] = new_resource.annotations if new_resource.annotations
      spec['expressions'] = new_resource.expressions
      spec['when'] = new_resource.when if new_resource.when
      spec['runtime_assets'] = new_resource.runtime_assets if new_resource.runtime_assets

      f = {}
      f['type'] = 'event_' + type_from_name
      f['spec'] = spec
      f
    end

    def mutator_from_resource
      spec = {}
      spec['command'] = new_resource.command
      spec['env_vars'] = new_resource.env_vars if new_resource.env_vars
      spec['metadata'] = {}
      spec['metadata']['name'] = new_resource.name
      spec['metadata']['namespace'] = new_resource.namespace
      spec['metadata']['labels'] = new_resource.labels if new_resource.labels
      spec['metadata']['annotations'] = new_resource.annotations if new_resource.annotations
      spec['timeout'] = new_resource.timeout if new_resource.timeout

      m = {}
      m['type'] = type_from_name
      m['spec'] = spec
      m
    end

    def entity_from_resource
      spec = {}
      spec['subscriptions'] = new_resource.subscriptions
      spec['metadata'] = {}
      spec['metadata']['name'] = new_resource.name
      spec['metadata']['namespace'] = new_resource.namespace
      spec['metadata']['labels'] = new_resource.labels if new_resource.labels
      spec['metadata']['annotations'] = new_resource.annotations if new_resource.annotations
      spec['entity_class'] = new_resource.entity_class

      e = {}
      e['type'] = type_from_name
      e['spec'] = spec
      e
    end

    def namespace_from_resource
      spec = {}
      spec['name'] = new_resource.name

      e = {}
      e['type'] = type_from_name
      e['spec'] = spec
      e
    end

    def latest_version?(version)
      version == 'latest' || version == :latest
    end
  end
end
