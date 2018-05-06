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
  its(%w(spec name)) { should eq 'cron' }
  its(%w(spec subscriptions)) { should include 'dad_jokes' }
end
