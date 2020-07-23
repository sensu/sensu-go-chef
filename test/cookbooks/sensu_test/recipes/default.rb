sensu_backend 'default' do
  action [:install, :init]
  username node['username']
  password node['password']
  debug true
end

sensu_agent 'default'

sensu_ctl 'default' do
  action [:install, :configure]
  username node['username']
  password node['password']
  debug true
end

sensu_namespace 'test-org' do
  action :create
end

sensu_check 'cron' do
  command '/bin/true'
  cron '@hourly'
  subscriptions %w(dad_jokes production)
  handlers %w(pagerduty email)
  labels(environment: 'production', region: 'us-west-2')
  annotations(runbook: 'https://www.xkcd.com/378/')
  publish false
  ttl 100
  high_flap_threshold 60
  low_flap_threshold 20
  subdue(days: { all: [{ begin: '12:00 AM', end: '11:59 PM' },
                       { begin: '11:00 PM', end: '1:00 AM' }] })
  action :create
end

assets = data_bag_item('sensu', 'assets')
assets.each do |name, property|
  next if name == 'id'
  sensu_asset name do
    url property['url']
    sha512 property['checksum']
    namespace property['namespace']
  end
end

sensu_handler 'slack' do
  type 'pipe'
  env_vars ['SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX']
  command 'sensu-slack-handler --channel monitoring'
  runtime_assets %w(sensu-slack-handler)
end

sensu_handler 'tcp_handler' do
  type 'tcp'
  socket(
    host: '127.0.0.1',
    port: 4444
  )
  timeout 30
end

sensu_handler 'udp_handler' do
  type 'udp'
  socket(
    host: '127.0.0.1',
    port: 4444
  )
  timeout 30
end

sensu_handler 'notify_the_world' do
  type 'set'
  handlers %w(slack tcp_handler udp_handler)
end

sensu_filter 'production_filter' do
  filter_action 'allow'
  expressions [
    "event.Entity.Environment == 'production'",
  ]
end

sensu_filter 'development_filter' do
  filter_action 'deny'
  expressions [
    "event.Entity.Environment == 'production'",
  ]
end

sensu_filter 'state_change_only' do
  filter_action 'allow'
  expressions [
    'event.Check.Occurrences == 1',
  ]
end

sensu_filter 'filter_interval_60_hourly' do
  filter_action 'allow'
  expressions [
    'event.Check.Interval == 60',
    'event.Check.Occurrences == 1 || event.Check.Occurrences % 60 == 0',
  ]
end

sensu_filter 'nine_to_fiver' do
  filter_action 'allow'
  expressions [
    'weekday(event.Timestamp) >= 1 && weekday(event.Timestamp) <= 5',
    'hour(event.Timestamp) >= 9 && hour(event.Timestamp) <= 17',
  ]
end

sensu_mutator 'example-mutator' do
  command 'example_mutator.rb'
  timeout 60
end

sensu_entity 'example-entity' do
  entity_class 'proxy'
  subscriptions ['example-entity']
  labels(environment: 'production', region: 'us-west-2')
  annotations(runbook: 'https://www.xkcd.com/378/')
  redact ['snmp_community_string']
  system(
    'hostname': 'example-hypervisor',
    'platform': 'Citrix Hypervisor',
    'platform_version': '8.1.0',
    'network': {
      'interfaces': [
        {
          'name': 'lo',
          'addresses': ['127.0.0.1/8'],
        },
        {
          'name': 'xapi0',
          'mac': '52:54:00:20:1b:3c',
          'addresses': ['172.0.1.72/24'],
        },
      ],
    }
  )
end

sensu_hook 'restart_cron_service' do
  command 'sudo service cron restart'
  timeout 60
end

sensu_role 'read_only' do
  namespace 'test-org'
  rules [ { resource_names: ['*'], verbs: %w(get list) } ]
end

sensu_cluster_role 'all_access' do
  rules [
    {
      resource_names: %w( assets checks entities events filters handlers hooks mutators rolebindings roles silenced cluster clusterrolebindings clusterroles namespaces users authproviders license ),
      verbs: %w( get list create update delete ),
    },
  ]
end

sensu_role_binding 'alice_read_only' do
  namespace 'test-org'
  role_name 'read_only'
  role_type 'Role'
  subjects [ { name: 'alice', type: 'user' } ]
end

sensu_cluster_role_binding 'cluster_admins-all_access' do
  role_name 'all_access'
  role_type 'ClusterRole'
  subjects [ { name: 'cluster-admins', type: 'Group' } ]
end

sensu_active_directory 'example-active-directory' do
  ad_servers [{
    'host': '127.0.0.1',
    'group_search': {
      'base_dn': 'dc=acme,dc=org',
    },
    'user_search': {
      'base_dn': 'dc=acme,dc=org',
    },
  }]
end

sensu_active_directory 'example-active-directory-alias' do
  servers [{
    'host': '127.0.0.1',
    'group_search': {
      'base_dn': 'dc=acme,dc=org',
    },
    'user_search': {
      'base_dn': 'dc=acme,dc=org',
    },
  }]
end

sensu_secrets_provider 'vault' do
  provider_type 'VaultProvider'
  address 'https://vaultserver.example.com:8200'
  max_retries 2
  rate_limiter(
    'limit': 10,
    'burst': 100
  )
  timeout '60s'
  token 'yourVaultToken'
  version 'v1'
end

sensu_secret 'env-secret' do
  namespace 'test-org'
  id 'CONSUL_TOKEN'
  secrets_provider 'env'
end

sensu_secret 'vault-secret' do
  namespace 'test-org'
  id 'secret/consul#token'
  secrets_provider 'vault'
end
