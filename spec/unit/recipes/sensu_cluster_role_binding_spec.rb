#
# Cookbook:: sensu-go
# Spec:: cluster_role_binding
#

# Copyright:: 2019 Sensu, Inc.
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

RSpec.shared_examples 'sensu_cluster_role_binding' do |platform, version|
  context "when run on #{platform} #{version}" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        os: 'linux',
        platform: platform,
        version: version,
        step_into: ['sensu_cluster_role_binding']
      ).converge(described_recipe)
    end

    include_context 'common_stubs'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates a directory' do
      expect(chef_run).to create_directory('/etc/sensu/cluster_role_bindings')
    end

    it 'creates sensu cluster role binding resources' do
      expect(chef_run).to create_sensu_cluster_role_binding('cluster_admins-all_access')
    end

    it 'creates cluster role binding object files' do
      expect(chef_run).to create_file('/etc/sensu/cluster_role_bindings/cluster_admins-all_access.json')
    end

    it 'creates the cluster_admins-all_access sensu cluster role binding' do
      expect(chef_run).to nothing_execute('sensuctl create -f /etc/sensu/cluster_role_bindings/cluster_admins-all_access.json')
    end
  end
end

RSpec.describe 'sensu_test::default' do
  platforms = {
    'ubuntu' => ['16.04', '18.04', '20.04'],
    'centos' => '7.6',
  }

  platforms.each do |platform, versions|
    versions = versions.is_a?(String) ? [versions] : versions
    versions.each do |version|
      include_examples 'sensu_cluster_role_binding', platform, version
    end
  end
end
