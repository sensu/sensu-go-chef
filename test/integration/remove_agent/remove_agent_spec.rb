#
# Cookbook:: sensu-go
# Spec:: agent
#
# Copyright:: 2019, The Authors, All Rights Reserved.

# The following are only examples, check out https://github.com/chef/inspec/tree/master/docs
# for everything you can do.
if os.linux?
  describe package('sensu-go-agent') do
    it { should_not be_installed }
  end

  describe service('sensu-agent') do
    it { should_not be_installed }
    # Ubuntu 14.04: Sensu pkg ships an init script, init provider doesn't support enable
    it { should_not be_enabled unless os.release.to_f == 14.04 }
    it { should_not be_running }
  end
end

if os.windows?
  describe package('Sensu Agent') do
    it { should_not be_installed }
  end

  describe service('SensuAgent') do
    it { should_not be_installed }
    it { should_not be_enabled }
    it { should_not be_running }
  end
end
