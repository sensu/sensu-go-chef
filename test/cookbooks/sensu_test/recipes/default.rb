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

sensu_user 'doofus' do
  password 'doofus1234'
  groups %w(view admin)
end

sensu_user 'doofus' do
  action :disable
end

sensu_user 'reinstated' do
  password 'a_smart_one'
  groups %w(view)
  action [:create, :disable, :reinstate]
end

sensu_user 'doofus' do
  groups %w(view admin managers)
  action :modify
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

sensu_check 'cron-test-org' do
  command '/bin/true'
  cron '@hourly'
  subscriptions %w(dad_jokes production)
  namespace 'test-org'
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
    headers property['headers'] if property['headers']
  end
end

sensu_asset 'multi-build' do
  builds [
    {
      'filters' => [
        "entity.system.os == 'linux'",
        "entity.system.arch == 'amd64'",
        "entity.system.platform_family == 'debian'",
        "entity.system.platform_version.split('.')[0] == '9'",
      ],
      'sha512' => 'a909f6eef2785302f648d5289fddfdd97014984e25751abb94ea70226ef8c5e56f9e333c054d79734c5f165f93494f34943aa9aa1ed06297fac599ff57328c27',
      'url' => 'https://assets.bonsai.sensu.io/058af8cde8fbdd97cfebf81a2565346e404210d5/sensu-plugins-postgres_4.0.0-pre-jef.1_debian9_linux_amd64.tar.gz',
    },
    {
      'filters' => [
        "entity.system.os == 'linux'",
        "entity.system.arch == 'amd64'",
        "entity.system.platform_family == 'debian'",
      ],
      'sha512' => 'b832ba248472e6c2713f60e946af322a8373e2144e6331afa6663ca13818b3c192e63f507dca1126d9b83b6c636b176a0e8e10a2a42292f457bf099f806ca57f',
      'url' => 'https://assets.bonsai.sensu.io/058af8cde8fbdd97cfebf81a2565346e404210d5/sensu-plugins-postgres_4.0.0-pre-jef.1_debian_linux_amd64.tar.gz',
    },
    {
      'filters' => [],
      'sha512' => '555889017fcbcc6319f08097b79c3efccc3bf8ed0f8e59913ff7a508d4fe3d3b347118de11961657cd8504bdfd32af51f3c4add4ac639e378e82a05178248853',
      'url' => 'https://assets.bonsai.sensu.io/058af8cde8fbdd97cfebf81a2565346e404210d5/sensu-plugins-postgres_4.0.0-pre-jef.1_centos6_linux_amd64.tar.gz',
    },
  ]
end

sensu_handler 'slack' do
  type 'pipe'
  env_vars ['SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX']
  command 'sensu-slack-handler --channel monitoring'
  runtime_assets %w(sensu-slack-handler)
end

sensu_handler 'slack-test-org' do
  type 'pipe'
  env_vars ['SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX']
  command 'sensu-slack-handler --channel monitoring'
  namespace 'test-org'
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

sensu_filter 'nine_to_fiver_test_org' do
  filter_action 'allow'
  expressions [
    'weekday(event.Timestamp) >= 1 && weekday(event.Timestamp) <= 5',
    'hour(event.Timestamp) >= 9 && hour(event.Timestamp) <= 17',
  ]
  namespace 'test-org'
end

sensu_mutator 'example-mutator' do
  command 'example_mutator.rb'
  timeout 60
end

sensu_mutator 'example-mutator-test-org' do
  command 'example_mutator.rb'
  namespace 'test-org'
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

sensu_entity 'example-entity-test-org' do
  entity_class 'proxy'
  subscriptions ['example-entity-test-org']
  namespace 'test-org'
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

sensu_hook 'restart_cron_service_test_org' do
  command 'sudo service cron restart'
  timeout 60
  namespace 'test-org'
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

sensu_auth_oidc 'fake_okta' do
  additional_scopes %w(groups email)
  client_id 'a8e43af034e7f2608780'
  # Demo only! The client secret value should come from somewhere like chef-vault
  client_secret 'b63968394be6ed2edb61c93847ee792f31bf6216'
  redirect_uri 'http://sensu-backend.example.com:8080/api/enterprise/authentication/v2/oidc/callback'
  server 'https://oidc.example.com:9031'
end

sensu_auth_ldap 'example-auth-ldap' do
  auth_servers [{
    'host': '127.0.0.1',
    'group_search': {
      'base_dn': 'dc=acme,dc=org',
    },
    'user_search': {
      'base_dn': 'dc=acme,dc=org',
    },
  }]
end

sensu_auth_ldap 'example-auth-ldap-alias' do
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

sensu_secret 'env-secret-default' do
  namespace 'default'
  id 'CONSUL_TOKEN'
  secrets_provider 'env'
end

sensu_etcd_replicator 'insecure_role_replicator' do
  insecure true
  url 'http://127.0.0.1:2379'
  resource 'Role'
end

sensu_etcd_replicator 'role_replicator' do
  cert '/etc/ssl/fake.pem'
  key '/etc/ssl/fake.key'
  url 'http://127.0.0.1:2379'
  resource 'Role'
end

sensu_etcd_replicator 'role_binding_replicator' do
  cert '/etc/ssl/fake.pem'
  key '/etc/ssl/fake.key'
  url 'http://127.0.0.1:2379'
  resource 'RoleBinding'
end

sensu_etcd_replicator 'cluster_role_replicator' do
  cert '/etc/ssl/fake.pem'
  key '/etc/ssl/fake.key'
  url 'http://127.0.0.1:2379'
  resource 'ClusterRole'
end

sensu_etcd_replicator 'cluster_role_binding_replicator' do
  cert '/etc/ssl/fake.pem'
  key '/etc/ssl/fake.key'
  url 'http://127.0.0.1:2379'
  resource 'ClusterRoleBinding'
end

sensu_search 'check-config' do
  parameters [
      'published:true',
      'subscription:linux',
      'labelSelector: region == \"us-west-1\"',
  ]
  resource 'core.v2/CheckConfig'
end

sensu_global_config 'custom-web-ui' do
  default_preferences(page_size: 50,
                      theme: 'deuteranopia')
  link_policy(allow_list: true,
              urls: [
                'https://example.com',
                'steamapp://34234234',
                '//google.com',
                '//*.google.com',
                '//bob.local',
              ])
end

sensu_tessen_config 'default' do
  opt_out true
end
