#
# Cookbook Name:: sensu-go
# Spec:: agent
#
# Copyright:: 2019, The Authors, All Rights Reserved.

# The following are only examples, check out https://github.com/chef/inspec/tree/master/docs
# for everything you can do.
if os.linux?
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

  describe package('sensu-go-agent') do
    it { should be_installed }
  end

  describe service('sensu-agent') do
    it { should be_installed }
    # Ubuntu 14.04: Sensu pkg ships an init script, init provider doesn't support enable
    it { should be_enabled unless os.release.to_f == 14.04 }
    it { should be_running }
  end
end

if os.windows?
  describe package('sensu agent') do
    it { should be_installed }
  end

  describe service('sensuagent') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
