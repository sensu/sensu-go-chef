#
# Cookbook:: sensu-go
# Spec:: sensu_postgres_config
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

RSpec.shared_examples 'sensu_postgres_config' do |platform, version|
  context "when run on #{platform} #{version}" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        os: 'linux',
        platform: platform,
        version: version,
        step_into: ['sensu_postgres_config']
      ).converge(described_recipe)
    end

    include_context 'common_stubs'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    # FIXME: object_dir helper is adding 's' suffix, ergo 'postgress'
    it 'creates a directory' do
      expect(chef_run).to create_directory('/etc/sensu/postgres_configs')
    end

    it 'creates sensu postgres config resources' do
      expect(chef_run).to create_sensu_postgres_config('sensu_pg')
    end

    it 'creates the postgres config object file' do
      expect(chef_run).to create_file('/etc/sensu/postgres_configs/sensu_pg.json')
    end

    it 'creates the sensu_pg PostgresConfig' do
      expect(chef_run).to nothing_execute('sensuctl create -f /etc/sensu/postgres_configs/sensu_pg.json')
    end
  end
end

RSpec.describe 'sensu_test::postgres' do
  platforms = {
    'ubuntu' => ['16.04', '18.04', '20.04'],
    'centos' => '7.6',
  }

  platforms.each do |platform, versions|
    versions = versions.is_a?(String) ? [versions] : versions
    versions.each do |version|
      include_examples 'sensu_postgres_config', platform, version
    end
  end
end
