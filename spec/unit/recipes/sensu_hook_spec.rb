#
# Cookbook Name:: sensu-go
# Spec:: sensu_hook
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

RSpec.shared_examples 'sensu_hook' do |platform, version|
  context "when run on #{platform} #{version}" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        os: 'linux',
        platform: platform,
        version: version,
        step_into: ['sensu_hook']
      ).converge(described_recipe)
    end

    include_context 'common_stubs'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates a directory' do
      expect(chef_run).to create_directory('/etc/sensu/hooks')
    end

    it 'creates sensu hook resources' do
      expect(chef_run).to create_sensu_hook('restart_cron_service')
    end

    it 'creates the hook object file' do
      expect(chef_run).to create_file('/etc/sensu/hooks/restart_cron_service.json')
#      expect(chef_run).to notify('execute[sensuctl create -f /etc/sensu/hooks/restart_cron_service.json]').to(:run)
    end

    it 'creates the restart_cron_service sensu hook' do
      expect(chef_run).to nothing_execute('sensuctl create -f /etc/sensu/hooks/restart_cron_service.json')
    end
  end
end

RSpec.describe 'sensu_test::default' do
  platforms = {
#    'ubuntu' => ['14.04', '16.04'],
    'centos' => '7.3.1611',
  }

  platforms.each do |platform, versions|
    versions = versions.is_a?(String) ? [versions] : versions
    versions.each do |version|
      include_examples 'sensu_hook', platform, version
    end
  end
end
