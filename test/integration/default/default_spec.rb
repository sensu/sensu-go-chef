#
# Cookbook Name:: sensu-go-chef
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

if os.family == 'debian'
  describe apt('https://packagecloud.io/sensu/nightly/ubuntu') do
    it { should exist }
    it { should be_enabled }
  end
end

describe package('sensu-backend') do
  it { should be_installed }
end

describe service('sensu-backend') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
