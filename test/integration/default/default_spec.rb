#
# Cookbook Name:: sensu-go
# Spec:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# The following are only examples, check out https://github.com/chef/inspec/tree/master/docs
# for everything you can do.
if os.redhat? || os.name == 'fedora' || os.name == 'amazon'
  describe yum.repo('sensu_beta') do
    it { should exist }
    it { should be_enabled }
  end
end

if os.name == 'debian' || os.name == 'ubuntu'
  describe apt("https://packagecloud.io/sensu/beta/#{os.name}") do
    it { should exist }
    it { should be_enabled }
  end
end

%w(sensu-backend sensu-agent).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end

  describe service(pkg) do
    it { should be_installed }
    # Ubuntu 14.04: Sensu pkg ships an init script, init provider doesn't support enable
    it { should be_enabled unless os.release.to_f == 14.04 }
    it { should be_running }
  end
end

describe package('sensu-cli') do
  it { should be_installed }
end

describe command('sensuctl user list') do
  its('stdout') { should match /Username/ }
  its('exit_status') { should eq 0 }
end

describe json('/etc/sensu/checks/cron.json') do
  its(%w(type)) { should eq 'check' }
  its(%w(spec metadata name)) { should eq 'cron' }
  its(%w(spec metadata namespace)) { should eq 'default' }
  its(%w(spec metadata annotations runbook)) { should eq 'https://www.xkcd.com/378/' }
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
    its(%w(type)) { should eq 'asset' }
    its(%w(spec metadata name)) { should eq "sensu-plugins-#{p}" }
    its(%w(spec metadata namespace)) { should eq 'default' }
    its(%w(spec url)) { should match URI::DEFAULT_PARSER.make_regexp }
  end
end

describe json('/etc/sensu/mutators/example-mutator.json') do
  its(%w(type)) { should eq 'mutator' }
  its(%w(spec metadata name)) { should eq 'example-mutator' }
  its(%w(spec metadata namespace)) { should eq 'default' }
  its(%w(spec timeout)) { should eq 60 }
end

describe json('/etc/sensu/entitys/example-entity.json') do
  its(%w(type)) { should eq 'entity' }
  its(%w(spec metadata name)) { should eq 'example-entity' }
  its(%w(spec subscriptions)) { should include 'example-entity' }
  its(%w(spec entity_class)) { should eq 'proxy' }
  its(%w(spec environment)) { should eq 'default' }
  its(%w(spec organization)) { should eq 'default' }
end

describe json('/etc/sensu/namespaces/test-org.json') do
  its(%w(type)) { should eq 'namespace' }
  its(%w(spec name)) { should eq 'test-org' }
end
