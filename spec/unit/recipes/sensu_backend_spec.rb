#
# Cookbook Name:: sensu-go
# Spec:: sensu_backend
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

RSpec.shared_examples 'sensu_backend' do |platform, version|
  context "when run on #{platform} #{version}" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        os: 'linux',
        platform: platform,
        version: version,
        step_into: ['sensu_backend']
      ).converge(described_recipe)
    end

    include_context 'common_stubs'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates sensu backend resources' do
      expect(chef_run).to install_sensu_backend('default')
    end

    it 'adds sensu packagecloud repo' do
      expect(chef_run).to add_packagecloud_repo('sensu/beta')
    end

    it 'writes the backend config file' do
      expect(chef_run).to create_file('/etc/sensu/backend.yml')
    end

    it 'installs package sensu-backend' do
      expect(chef_run).to upgrade_package('sensu-backend')
    end

    it 'enables and starts sensu-backend service' do
      expect(chef_run).to enable_service('sensu-backend') unless version == '14.04'
      expect(chef_run).to start_service('sensu-backend')
    end
  end
end

RSpec.describe 'sensu_test::default' do
  platforms = {
    'ubuntu' => ['14.04', '16.04'],
    'centos' =>  '7.3.1611',
  }

  platforms.each do |platform, versions|
    versions = versions.is_a?(String) ? [versions] : versions
    versions.each do |version|
      include_examples 'sensu_backend', platform, version
    end
  end
end
