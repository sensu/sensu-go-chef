module SensuCookbook
  module Helpers
    # Extract object type from resource type
    def type_from_name
      name_elements = new_resource.declared_type.to_s.split('_')
      name_elements.reject { |x| x == 'sensu' }.collect(&:capitalize).join
    end

    # Pluralize object directory name
    def object_dir
      dirname = new_resource.declared_type.to_s.gsub(/^sensu_/, '')
      ::File.join(new_resource.config_home, dirname) + 's'
    end

    def object_file
      ::File.join(object_dir, new_resource.name) + '.json'
    end

    def base_resource(new_resource, spec = Mash.new, api_version = 'core/v2')
      obj = Mash.new
      meta = Mash.new

      meta['name'] = new_resource.name
      meta['labels'] = new_resource.labels if new_resource.labels
      meta['annotations'] = new_resource.annotations if new_resource.annotations

      obj['metadata'] = meta
      obj['type'] = type_from_name
      obj['api_version'] = api_version
      obj['spec'] = spec
      obj
    end

    # Get check properties from the resource
    # https://docs.sensu.io/sensu-core/2.0/reference/checks/#check-attributes
    def check_from_resource
      spec = {}
      spec['check_hooks'] = new_resource.check_hooks if new_resource.check_hooks
      spec['command'] = new_resource.command
      spec['cron'] = new_resource.cron
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

      c = base_resource(new_resource, spec)
      c['metadata']['namespace'] = new_resource.namespace
      c
    end

    def asset_from_resource
      spec = {}
      spec['sha512'] = new_resource.sha512
      spec['url'] = new_resource.url

      a = base_resource(new_resource, spec)
      a['metadata']['namespace'] = new_resource.namespace
      a
    end

    def handler_from_resource
      spec = {}
      spec['command'] = new_resource.command if new_resource.command
      spec['env_vars'] = new_resource.env_vars if new_resource.env_vars
      spec['filters'] = new_resource.filters if new_resource.filters
      spec['handlers'] = new_resource.handlers if new_resource.handlers
      spec['mutator'] = new_resource.mutator if new_resource.mutator
      spec['runtime_assets'] = new_resource.runtime_assets if new_resource.runtime_assets
      spec['socket'] = new_resource.socket if new_resource.socket
      spec['timeout'] = new_resource.timeout if new_resource.timeout
      spec['type'] = new_resource.type

      h = base_resource(new_resource, spec)
      h['metadata']['namespace'] = new_resource.namespace
      h
    end

    def hook_from_resource
      spec = {}
      spec['command'] = new_resource.command if new_resource.command
      spec['timeout'] = new_resource.timeout if new_resource.timeout
      spec['stdin'] = new_resource.stdin if new_resource.stdin

      h = base_resource(new_resource, spec)
      h['metadata']['namespace'] = new_resource.namespace
      h
    end

    def filter_from_resource
      spec = {}
      spec['action'] = new_resource.filter_action
      spec['expressions'] = new_resource.expressions
      spec['when'] = new_resource.when if new_resource.when
      spec['runtime_assets'] = new_resource.runtime_assets if new_resource.runtime_assets

      f = base_resource(new_resource, spec)
      f['type'] = 'Event' + type_from_name
      f['metadata']['namespace'] = new_resource.namespace
      f
    end

    def mutator_from_resource
      spec = {}
      spec['command'] = new_resource.command
      spec['env_vars'] = new_resource.env_vars if new_resource.env_vars
      spec['timeout'] = new_resource.timeout if new_resource.timeout

      m = base_resource(new_resource, spec)
      m['metadata']['namespace'] = new_resource.namespace
      m
    end

    def entity_from_resource
      spec = {}
      spec['subscriptions'] = new_resource.subscriptions
      spec['entity_class'] = new_resource.entity_class

      e = base_resource(new_resource, spec)
      e['metadata']['namespace'] = new_resource.namespace
      e
    end

    def namespace_from_resource
      e = {
        'type' => type_from_name,
        'spec' => { 'name' => new_resource.name },
      }
      e
    end

    def role_from_resource
      spec = {
        'rules' => new_resource.rules,
      }

      role = base_resource(new_resource, spec)
      role['metadata']['namespace'] = new_resource.namespace
      role
    end

    def cluster_role_from_resource
      spec = {
        'rules' => new_resource.rules,
      }
      crole = base_resource(new_resource, spec)
      crole
    end

    def role_binding_from_resource
      spec = {
        'role_ref' => {
          'name' => new_resource.role_name,
          'type' => new_resource.role_type,
        },
        'subjects' => new_resource.subjects,
      }

      binding = base_resource(new_resource, spec)
      binding['metadata']['namespace'] = new_resource.namespace
      binding
    end

    def cluster_role_binding_from_resource
      spec = {
        'role_ref' => {
          'name' => new_resource.role_name,
          'type' => new_resource.role_type,
        },
        'subjects' => new_resource.subjects,
      }

      cbinding = base_resource(new_resource, spec)
      cbinding
    end

    def postgres_cfg_from_resource
      spec = {
        'dsn' => new_resource.dsn,
      }
      spec['pool_size'] = new_resource.pool_size if new_resource.pool_size
      obj = base_resource(new_resource, spec, 'store/v1')
      obj
    end

    def latest_version?(version)
      version == 'latest' || version == :latest
    end
  end
end
