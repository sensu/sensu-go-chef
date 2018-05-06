#
# Cookbook Name:: sensu-go
# Spec:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# The following are only examples, check out https://github.com/chef/inspec/tree/master/docs
# for everything you can do.
if os.redhat? || os.name == 'fedora' || os.name == 'amazon'
  describe yum.repo('sensu_nightly') do
    it { should exist }
    it { should be_enabled }
  end
end

if os.name == 'debian' || os.name == 'ubuntu'
  describe apt("https://packagecloud.io/sensu/nightly/#{os.name}") do
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
  its(%w(type)) { should eq 'Check' }
  its(%w(spec name)) { should eq 'cron' }
  its(%w(spec cron)) { should eq '@hourly' }
  its(%w(spec environment)) { should eq 'default' }
  its(%w(spec subscriptions)) { should include 'dad_jokes' }
  its(%w(spec subscriptions)) { should include 'production' }
  its(%w(spec handlers)) { should include 'pagerduty' }
  its(%w(spec handlers)) { should include 'email' }
  its(%w(spec extended_attributes runbook)) { should eq 'https://www.xkcd.com/378/' }
  its(['spec', 'subdue', 'days', 'all', 0, 'begin']) { should eq '12:00 AM' }
  its(['spec', 'subdue', 'days', 'all', 0, 'end']) { should eq '11:59 PM' }
  its(['spec', 'subdue', 'days', 'all', 1, 'begin']) { should eq '11:00 PM' }
  its(['spec', 'subdue', 'days', 'all', 1, 'end']) { should eq '1:00 AM' }
end
