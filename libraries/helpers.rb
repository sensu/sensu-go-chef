module SensuCookbook
  module Helpers
    # Extract object type from resource type
    def type_from_name
      name_elements = new_resource.declared_type.to_s.split('_')
      name_elements.reject { |x| x == 'sensu' }.collect(&:capitalize).join
    end

    # Pluralize object directory name
    def object_dir(plural = true)
      dirname = new_resource.declared_type.to_s.gsub(/^sensu_/, '')
      if plural
        ::File.join(new_resource.config_home, dirname) + 's'
      else
        ::File.join(new_resource.config_home, dirname)
      end
    end

    def object_file(plural = true)
      ::File.join(object_dir(plural), new_resource.name) + '.json'
    end

    def base_resource(new_resource, spec = Mash.new, api_version = 'core/v2')
      obj = Mash.new
      meta = Mash.new

      meta['name'] = new_resource.name
      meta['labels'] = new_resource.labels if new_resource.labels
      meta['annotations'] = new_resource.annotations if new_resource.annotations

      obj['metadata'] = meta
      obj['type'] = if defined?(new_resource.resource_type)
                      new_resource.resource_type
                    else
                      type_from_name
                    end
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
      spec['secrets'] = new_resource.secrets if new_resource.secrets
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
      if new_resource.builds.empty?
        spec['sha512'] = new_resource.sha512
        spec['url'] = new_resource.url
        spec['filters'] = new_resource.filters if new_resource.filters
      else
        spec['builds'] = new_resource.builds
      end
      spec['headers'] = new_resource.headers if new_resource.headers
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
      spec['secrets'] = new_resource.secrets if new_resource.secrets
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
      spec['secrets'] = new_resource.secrets if new_resource.secrets
      spec['timeout'] = new_resource.timeout if new_resource.timeout

      m = base_resource(new_resource, spec)
      m['metadata']['namespace'] = new_resource.namespace
      m
    end

    def entity_from_resource
      spec = {}
      spec['deregister'] = new_resource.deregister if new_resource.deregister
      spec['deregistration'] = new_resource.deregistration if new_resource.deregistration
      spec['entity_class'] = new_resource.entity_class
      spec['redact'] = new_resource.redact if new_resource.redact
      spec['sensu_agent_version'] = new_resource.sensu_agent_version if new_resource.sensu_agent_version
      spec['subscriptions'] = new_resource.subscriptions
      spec['system'] = new_resource.system if new_resource.system
      spec['user'] = new_resource.user if new_resource.user

      e = base_resource(new_resource, spec)
      e['metadata']['namespace'] = new_resource.namespace
      e
    end

    def namespace_from_resource
      {
        'type' => type_from_name,
        'spec' => { 'name' => new_resource.name },
      }
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
      base_resource(new_resource, spec)
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

      base_resource(new_resource, spec)
    end

    def postgres_cfg_from_resource
      spec = {
        'dsn' => new_resource.dsn,
      }
      spec['pool_size'] = new_resource.pool_size if new_resource.pool_size
      base_resource(new_resource, spec, 'store/v1')
    end

    def active_directory_from_resource
      spec = {}
      spec['servers'] = new_resource.ad_servers
      spec['groups_prefix'] = new_resource.groups_prefix if new_resource.groups_prefix
      spec['username_prefix'] = new_resource.username_prefix if new_resource.groups_prefix
      base_resource(new_resource, spec, 'authentication/v2')
    end

    def auth_oidc_from_resource
      spec = {}
      spec['additional_scopes'] = new_resource.additional_scopes if new_resource.additional_scopes
      spec['client_id'] = new_resource.client_id
      spec['client_secret'] = new_resource.client_secret
      spec['disable_offline_access'] = new_resource.disable_offline_access
      spec['redirect_uri'] = new_resource.redirect_uri if new_resource.redirect_uri
      spec['server'] = new_resource.server
      spec['groups_claim'] = new_resource.groups_claim
      spec['groups_prefix'] = new_resource.groups_prefix if new_resource.groups_prefix
      spec['username_claim'] = new_resource.username_claim
      spec['username_prefix'] = new_resource.username_prefix if new_resource.username_prefix
      base_resource(new_resource, spec, 'authentication/v2')
    end

    def secret_from_resource
      spec = {}
      spec['id'] = new_resource.id
      spec['provider'] = new_resource.secrets_provider
      secret = base_resource(new_resource, spec, 'secrets/v1')
      secret['metadata']['namespace'] = new_resource.namespace
      secret
    end

    def secrets_provider_from_resource
      spec = { 'client' => {} }
      spec['client']['address'] = new_resource.address
      spec['client']['max_retries'] = new_resource.max_retries if new_resource.max_retries
      spec['client']['rate_limiter'] = new_resource.rate_limiter if new_resource.rate_limiter
      spec['client']['timeout'] = new_resource.timeout if new_resource.timeout
      spec['client']['tls'] = new_resource.tls if new_resource.tls
      spec['client']['token'] = new_resource.token if new_resource.token
      spec['client']['version'] = new_resource.version
      base_resource(new_resource, spec, 'secrets/v1')
    end

    def etcd_replicator_from_resource
      spec = {}
      unless new_resource.insecure
        # Only required if insecure: false, meaning disabled transport security
        spec['ca_cert'] = new_resource.ca_cert
        spec['cert'] = new_resource.cert
        spec['key'] = new_resource.cert
      end
      spec['insecure'] = new_resource.insecure
      spec['url'] = new_resource.url
      spec['api_version'] = new_resource.api_version
      spec['resource'] = new_resource.resource
      spec['namespace'] = new_resource.namespace if new_resource.namespace
      spec['replication_interval_seconds'] = new_resource.replication_interval_seconds
      replicator = base_resource(new_resource, spec, 'federation/v1')
      replicator['metadata']['created_by'] = 'chef-client'
      replicator
    end

    def latest_version?(version)
      version == 'latest' || version == :latest
    end
  end
end
