#
# Cookbook:: sensu-go
# Spec:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

# The following are only examples, check out https://github.com/chef/inspec/tree/master/docs
# for everything you can do.
if os.redhat? || os.name == 'fedora' || os.name == 'amazon'
  describe yum.repo('sensu_stable') do
    it { should exist }
    it { should be_enabled }
  end
end

if os.name == 'debian' || os.name == 'ubuntu'
  describe apt("https://packagecloud.io/sensu/stable/#{os.name}") do
    it { should exist }
    it { should be_enabled }
  end
end

%w(sensu-go-backend sensu-go-agent sensu-go-cli).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

%w(sensu-backend sensu-agent).each do |svc|
  describe service(svc) do
    it { should be_installed }
    # Ubuntu 14.04: Sensu pkg ships an init script, init provider doesn't support enable
    it { should be_enabled unless os.release.to_f == 14.04 }
    it { should be_running }
  end
end

describe command('sensuctl user list') do
  its('stdout') { should match /Username/ }
  its('exit_status') { should eq 0 }
end

describe json(command: 'sensuctl user list --format json') do
  # Referrencing returned elements of the array by index feels fragile
  its([0, 'username']) { should cmp 'admin' }
  its([0, 'disabled']) { should cmp 'false' }
  its([1, 'username']) { should cmp 'agent' }
  its([2, 'username']) { should cmp 'doofus' }
  its([2, 'groups']) { should include 'admin' }
  its([2, 'groups']) { should include 'managers' }
  its([2, 'disabled']) { should cmp 'true' }
  its([3, 'username']) { should cmp 'reinstated' }
  its([3, 'groups']) { should include 'view' }
  its([3, 'disabled']) { should cmp 'false' }
end

describe json('/etc/sensu/checks/cron.json') do
  its(%w(type)) { should eq 'Check' }
  its(%w(metadata name)) { should eq 'cron' }
  its(%w(metadata namespace)) { should eq 'default' }
  its(%w(metadata annotations runbook)) { should eq 'https://www.xkcd.com/378/' }
  its(%w(spec cron)) { should eq '@hourly' }
  its(%w(spec subscriptions)) { should include 'dad_jokes' }
  its(%w(spec subscriptions)) { should include 'production' }
  its(%w(spec handlers)) { should include 'pagerduty' }
  its(%w(spec handlers)) { should include 'email' }
  its(['spec', 'subdue', 'days', 'all', 0, 'begin']) { should eq '12:00 AM' }
  its(['spec', 'subdue', 'days', 'all', 0, 'end']) { should eq '11:59 PM' }
  its(['spec', 'subdue', 'days', 'all', 1, 'begin']) { should eq '11:00 PM' }
  its(['spec', 'subdue', 'days', 'all', 1, 'end']) { should eq '1:00 AM' }
end

describe json('/etc/sensu/checks/cron-test-org.json') do
  its(%w(type)) { should eq 'Check' }
  its(%w(metadata name)) { should eq 'cron-test-org' }
  its(%w(metadata namespace)) { should eq 'test-org' }
  its(%w(metadata annotations runbook)) { should eq 'https://www.xkcd.com/378/' }
  its(%w(spec cron)) { should eq '@hourly' }
  its(%w(spec subscriptions)) { should include 'dad_jokes' }
  its(%w(spec subscriptions)) { should include 'production' }
  its(%w(spec handlers)) { should include 'pagerduty' }
  its(%w(spec handlers)) { should include 'email' }
  its(['spec', 'subdue', 'days', 'all', 0, 'begin']) { should eq '12:00 AM' }
  its(['spec', 'subdue', 'days', 'all', 0, 'end']) { should eq '11:59 PM' }
  its(['spec', 'subdue', 'days', 'all', 1, 'begin']) { should eq '11:00 PM' }
  its(['spec', 'subdue', 'days', 'all', 1, 'end']) { should eq '1:00 AM' }
end

%w(http docker postgres).each do |p|
  describe json("/etc/sensu/assets/sensu-plugins-#{p}.json") do
    require 'uri'
    its(%w(type)) { should eq 'Asset' }
    its(%w(metadata name)) { should eq "sensu-plugins-#{p}" }
    its(%w(metadata namespace)) { should eq 'default' }
    its(%w(spec url)) { should match URI::DEFAULT_PARSER.make_regexp }
  end
end

# http test data has optional header field defined
describe json('/etc/sensu/assets/sensu-plugins-http.json') do
  its(%w(spec headers X-Forwarded-For)) { should eq 'client1, proxy1, proxy2' }
end

describe json('/etc/sensu/assets/multi-build.json') do
  require 'uri'
  its(%w(type)) { should eq 'Asset' }
  its(%w(metadata name)) { should eq 'multi-build' }
  its(%w(metadata namespace)) { should eq 'default' }
  its(['spec', 'builds', 0, 'url']) { should match URI::DEFAULT_PARSER.make_regexp }
end

describe json('/etc/sensu/assets/sensu-plugins-disk-checks.json') do
  require 'uri'
  its(%w(type)) { should eq 'Asset' }
  its(%w(metadata name)) { should eq 'sensu-plugins-disk-checks' }
  its(%w(metadata namespace)) { should eq 'test-org' }
  its(%w(spec url)) { should match URI::DEFAULT_PARSER.make_regexp }
end

describe json('/etc/sensu/assets/sensu-plugins-docker.json') do
  require 'uri'
  its(%w(type)) { should eq 'Asset' }
  its(%w(metadata name)) { should eq 'sensu-plugins-docker' }
  its(%w(spec headers)) { should eq '{"Authorization"=>"Basic $ENV-SECRET-DEFAULT"}' }
  its(['spec', 'secrets', 0, 'name']) { should eq 'ENV-SECRET-DEFAULT' }
  its(['spec', 'secrets', 0, 'secret']) { should eq 'env-secret-default' }
end

describe json('/etc/sensu/handlers/slack.json') do
  its(%w(type)) { should eq 'Handler' }
  its(%w(metadata name)) { should eq 'slack' }
  its(%w(metadata namespace)) { should eq 'default' }
  its(%w(spec command)) { should eq 'sensu-slack-handler --channel monitoring' }
  its(%w(spec env_vars)) { should include 'SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX' }
  its(%w(spec type)) { should eq 'pipe' }
  its(%w(spec runtime_assets)) { should include 'sensu-slack-handler' }
end

describe json('/etc/sensu/handlers/slack-test-org.json') do
  its(%w(type)) { should eq 'Handler' }
  its(%w(metadata name)) { should eq 'slack-test-org' }
  its(%w(metadata namespace)) { should eq 'test-org' }
  its(%w(spec command)) { should eq 'sensu-slack-handler --channel monitoring' }
  its(%w(spec env_vars)) { should include 'SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX' }
  its(%w(spec type)) { should eq 'pipe' }
  its(%w(spec runtime_assets)) { should include 'sensu-slack-handler' }
end

describe json('/etc/sensu/mutators/example-mutator.json') do
  its(%w(type)) { should eq 'Mutator' }
  its(%w(metadata name)) { should eq 'example-mutator' }
  its(%w(metadata namespace)) { should eq 'default' }
  its(%w(spec timeout)) { should eq 60 }
end

describe json('/etc/sensu/mutators/example-mutator-test-org.json') do
  its(%w(type)) { should eq 'Mutator' }
  its(%w(metadata name)) { should eq 'example-mutator-test-org' }
  its(%w(metadata namespace)) { should eq 'test-org' }
  its(%w(spec timeout)) { should eq 60 }
end

describe json('/etc/sensu/entitys/example-entity.json') do
  its(%w(type)) { should eq 'Entity' }
  its(%w(metadata name)) { should eq 'example-entity' }
  its(%w(spec entity_class)) { should eq 'proxy' }
  its(%w(spec subscriptions)) { should include 'example-entity' }
  its(%w(metadata namespace)) { should eq 'default' }
  its(%w(metadata labels environment)) { should eq 'production' }
  its(%w(metadata labels region)) { should eq 'us-west-2' }
  its(%w(metadata annotations runbook)) { should eq 'https://www.xkcd.com/378/' }
  its(%w(spec redact)) { should include 'snmp_community_string' }
  its(%w(spec system hostname)) { should eq 'example-hypervisor' }
  its(%w(spec system platform)) { should eq 'Citrix Hypervisor' }
  its(%w(spec system platform_version)) { should eq '8.1.0' }
end

describe json('/etc/sensu/entitys/example-entity-test-org.json') do
  its(%w(type)) { should eq 'Entity' }
  its(%w(metadata name)) { should eq 'example-entity-test-org' }
  its(%w(spec entity_class)) { should eq 'proxy' }
  its(%w(spec subscriptions)) { should include 'example-entity-test-org' }
  its(%w(metadata namespace)) { should eq 'test-org' }
  its(%w(metadata labels environment)) { should eq 'production' }
  its(%w(metadata labels region)) { should eq 'us-west-2' }
  its(%w(metadata annotations runbook)) { should eq 'https://www.xkcd.com/378/' }
  its(%w(spec redact)) { should include 'snmp_community_string' }
  its(%w(spec system hostname)) { should eq 'example-hypervisor' }
  its(%w(spec system platform)) { should eq 'Citrix Hypervisor' }
  its(%w(spec system platform_version)) { should eq '8.1.0' }
end

describe json('/etc/sensu/namespaces/test-org.json') do
  its(%w(type)) { should eq 'Namespace' }
  its(%w(spec name)) { should eq 'test-org' }
end

describe json('/etc/sensu/hooks/restart_cron_service.json') do
  its(%w(type)) { should eq 'Hook' }
  its(%w(metadata name)) { should eq 'restart_cron_service' }
  its(%w(metadata namespace)) { should eq 'default' }
  its(%w(spec command)) { should eq 'sudo service cron restart' }
  its(%w(spec timeout)) { should eq 60 }
end

describe json('/etc/sensu/hooks/restart_cron_service_test_org.json') do
  its(%w(type)) { should eq 'Hook' }
  its(%w(metadata name)) { should eq 'restart_cron_service_test_org' }
  its(%w(metadata namespace)) { should eq 'test-org' }
  its(%w(spec command)) { should eq 'sudo service cron restart' }
  its(%w(spec timeout)) { should eq 60 }
end

describe json('/etc/sensu/cluster_roles/all_access.json') do
  its(%w(type)) { should eq 'ClusterRole' }
  its(%w(metadata name)) { should eq 'all_access' }
end

describe json('/etc/sensu/cluster_role_bindings/cluster_admins-all_access.json') do
  its(%w(type)) { should eq 'ClusterRoleBinding' }
  its(%w(metadata name)) { should eq 'cluster_admins-all_access' }
  its(%w(spec role_ref name)) { should eq 'all_access' }
  its(%w(spec role_ref type)) { should eq 'ClusterRole' }
end

describe json('/etc/sensu/roles/read_only.json') do
  its(%w(type)) { should eq 'Role' }
  its(%w(metadata name)) { should eq 'read_only' }
  its(%w(metadata namespace)) { should eq 'test-org' }
end

describe json('/etc/sensu/role_bindings/alice_read_only.json') do
  its(%w(type)) { should eq 'RoleBinding' }
  its(%w(metadata name)) { should eq 'alice_read_only' }
  its(%w(metadata namespace)) { should eq 'test-org' }
end

%w(example-active-directory example-active-directory-alias).each do |ad_name|
  describe json("/etc/sensu/active_directory/#{ad_name}.json") do
    its(%w(type)) { should eq 'ad' }
    its(%w(api_version)) { should eq 'authentication/v2' }
    its(%w(metadata name)) { should eq ad_name }
  end
end

describe json('/etc/sensu/auth_oidc/fake_okta.json') do
  its(%w(type)) { should eq 'oidc' }
  its(%w(metadata name)) { should eq 'fake_okta' }
  its(%w(api_version)) { should eq 'authentication/v2' }
  its(%w(spec client_id)) { should eq 'a8e43af034e7f2608780' }
  its(%w(spec client_secret)) { should eq 'b63968394be6ed2edb61c93847ee792f31bf6216' }
  its(%w(spec additional_scopes)) { should include 'groups' }
  its(%w(spec disable_offline_access)) { should eq false }
  its(%w(spec redirect_uri)) { should eq 'http://sensu-backend.example.com:8080/api/enterprise/authentication/v2/oidc/callback' }
  its(%w(spec server)) { should eq 'https://oidc.example.com:9031' }
  its(%w(spec groups_claim)) { should eq 'groups' }
  its(%w(spec username_claim)) { should eq 'email' }
end

%w(example-auth-ldap example-auth-ldap-alias).each do |ldap_name|
  describe json("/etc/sensu/auth_ldap/#{ldap_name}.json") do
    its(%w(type)) { should eq 'ldap' }
    its(%w(api_version)) { should eq 'authentication/v2' }
    its(%w(metadata name)) { should eq ldap_name }
  end
end

describe json('/etc/sensu/secrets_providers/vault.json') do
  its(%w(type)) { should eq 'VaultProvider' }
  its(%w(metadata name)) { should eq 'vault' }
  its(%w(spec client address)) { should eq 'https://vaultserver.example.com:8200' }
  its(%w(spec client max_retries)) { should eq 2 }
  its(%w(spec client rate_limiter limit)) { should eq 10 }
  its(%w(spec client rate_limiter burst)) { should eq 100 }
  its(%w(spec client timeout)) { should eq '60s' }
  its(%w(spec client token)) { should eq 'yourVaultToken' }
end

describe json('/etc/sensu/secrets/env-secret.json') do
  its(%w(type)) { should eq 'Secret' }
  its(%w(metadata name)) { should eq 'env-secret' }
  its(%w(metadata namespace)) { should eq 'test-org' }
  its(%w(spec id)) { should eq 'CONSUL_TOKEN' }
  its(%w(spec provider)) { should eq 'env' }
end

describe json('/etc/sensu/secrets/vault-secret.json') do
  its(%w(type)) { should eq 'Secret' }
  its(%w(metadata name)) { should eq 'vault-secret' }
  its(%w(metadata namespace)) { should eq 'test-org' }
  its(%w(spec id)) { should eq 'secret/consul#token' }
  its(%w(spec provider)) { should eq 'vault' }
end

describe json('/etc/sensu/secrets/env-secret-default.json') do
  its(%w(type)) { should eq 'Secret' }
  its(%w(metadata name)) { should eq 'env-secret-default' }
  its(%w(metadata namespace)) { should eq 'default' }
  its(%w(spec id)) { should eq 'CONSUL_TOKEN' }
  its(%w(spec provider)) { should eq 'env' }
end

%w(cluster_role_binding_replicator
  cluster_role_replicator
  insecure_role_replicator
  role_binding_replicator
  role_replicator).each do |replicator|
  describe json("/etc/sensu/etcd_replicator/#{replicator}.json") do
    its(%w(type)) { should eq 'EtcdReplicator' }
    its(%w(api_version)) { should eq 'federation/v1' }
    its(%w(metadata created_by)) { should eq 'chef-client' }
    its(%w(spec url)) { should eq 'http://127.0.0.1:2379' }
    its(%w(spec resource)) { should be_in 'Role RoleBinding ClusterRole ClusterRoleBinding' }
  end
end

%w(cluster_role_binding_replicator
  cluster_role_replicator
  role_binding_replicator
  role_replicator).each do |replicator|
  describe json("/etc/sensu/etcd_replicator/#{replicator}.json") do
    its(%w(spec insecure)) { should eq false }
  end
end

describe json('/etc/sensu/etcd_replicator/insecure_role_replicator.json') do
  its(%w(spec insecure)) { should eq true }
end

describe json('/etc/sensu/search/check-config.json') do
  its(%w(type)) { should eq 'Search' }
  its(%w(metadata name)) { should eq 'check-config' }
  its(%w(metadata namespace)) { should eq 'default' }
  its(%w(spec resource)) { should eq 'core.v2/CheckConfig' }
end

describe json('/etc/sensu/global_config/custom-web-ui.json') do
  its(%w(type)) { should eq 'GlobalConfig' }
  its(%w(api_version)) { should eq 'web/v1' }
  its(%w(metadata created_by)) { should eq 'chef-client' }
  its(%w(spec default_preferences theme)) { should eq 'deuteranopia' }
  its(%w(spec link_policy allow_list)) { should eq true }
end

describe json('/etc/sensu/tessen_config/default.json') do
  its(%w(spec opt_out)) { should eq true }
end
