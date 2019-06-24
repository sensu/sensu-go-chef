#
# Cookbook Name:: sensu-go
# Spec:: sensu_agent
#

# Copyright:: 2018 Sensu, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

RSpec.shared_examples 'sensu_agent_nix' do |platform, version|
  context "when run on #{platform} #{version}" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        os: 'linux',
        platform: platform,
        version: version,
        step_into: ['sensu_agent']
      ).converge(described_recipe)
    end

    include_context 'common_stubs'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates sensu agent resources' do
      expect(chef_run).to install_sensu_backend('default')
    end

    it 'adds sensu packagecloud repo' do
      expect(chef_run).to add_packagecloud_repo('sensu/stable')
    end

    it 'writes the agent config file' do
      expect(chef_run).to create_file('/etc/sensu/agent.yml')
    end

    it 'installs package sensu-agent' do
      expect(chef_run).to upgrade_package('sensu-go-agent')
    end

    it 'enables and starts sensu-agent service' do
      expect(chef_run).to enable_service('sensu-agent') unless version == '14.04'
      expect(chef_run).to start_service('sensu-agent')
    end
  end
end

RSpec.shared_examples 'sensu_agent_win' do |platform, version|
  context "when run on #{platform} #{version}" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        os: 'windows',
        platform: platform,
        version: version,
        step_into: ['sensu_agent']
      ).converge(described_recipe)
    end

    include_context 'common_stubs'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs package sensu agent' do
      expect(chef_run).to install_windows_package('sensu-go-agent')
    end

    it 'adds a path to windows variable' do
      expect(chef_run).to add_windows_path('c:\Program Files\sensu\sensu-agent\bin')
    end

    it 'writes the agent config file' do
      expect(chef_run).to create_file('c:/ProgramData/Sensu/config/agent.yml')
    end

    it 'runs a powershell script' do
      expect(chef_run).to run_powershell_script('SensuAgent Service')
    end

    it 'enables and starts sensuagent service' do
      expect(chef_run).to enable_service('SensuAgent')
      expect(chef_run).to start_service('SensuAgent')
    end
  end
end

RSpec.describe 'sensu_test::default' do
  nix_platforms = {
    'ubuntu' => ['14.04', '16.04'],
    'centos' => '7.3.1611',
  }
  win_platforms = {
    'windows' => %w(2012r2 2016 2019),
  }

  nix_platforms.each do |platform, versions|
    versions = versions.is_a?(String) ? [versions] : versions
    versions.each do |version|
      include_examples 'sensu_agent_nix', platform, version
    end
  end

  win_platforms.each do |platform, versions|
    versions = versions.is_a?(String) ? [versions] : versions
    versions.each do |version|
      include_examples 'sensu_agent_win', platform, version
    end
  end
end
