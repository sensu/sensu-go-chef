#
# Cookbook:: sensu-go
# Spec:: sensu_ctl
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

RSpec.shared_examples 'sensu_ctl' do |platform, version|
  context "when run on #{platform} #{version}" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        os: 'linux',
        platform: platform,
        version: version,
        step_into: ['sensu_ctl']
      ).converge(described_recipe)
    end

    include_context 'common_stubs'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates sensu ctl resources' do
      expect(chef_run).to install_sensu_ctl('default')
    end

    it 'adds sensu packagecloud repo' do
      expect(chef_run).to add_packagecloud_repo('sensu/stable')
    end

    it 'installs package sensu-cli' do
      expect(chef_run).to install_package('sensu-go-cli')
    end

    it 'configures the sensu cli' do
      expect(chef_run).to configure_sensu_ctl('default')
    end
  end
end

RSpec.shared_examples 'sensu_ctl_win' do |platform, version|
  context "when run on #{platform} #{version}" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        os: 'windows',
        platform: platform,
        version: version,
        step_into: ['sensu_ctl']
      ).converge(described_recipe)
    end

    include_context 'common_stubs'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'includes the `seven_zip::default` recipe' do
      expect(chef_run).to include_recipe('seven_zip::default')
    end

    it 'creates a directory `c:\sensutemp`' do
      expect(chef_run).to create_directory('c:\sensutemp')
    end

    it 'extracts an archive' do
      expect(chef_run).to extract_seven_zip_archive('Extract Sensuctl Gz')
    end

    it 'extracts the archive' do
      expect(chef_run).to extract_seven_zip_archive('Extract Sensuctl Tar')
    end

    it 'creates a directory `c:\Program Files\Sensu\sensu-cli\bin\sensuctl`' do
      expect(chef_run).to create_directory('c:\Program Files\Sensu\sensu-cli\bin\sensuctl')
    end

    it 'creates a remote_file `c:\Program Files\Sensu\sensu-cli\bin\sensuctl\sensuctl.exe`' do
      expect(chef_run).to create_remote_file('c:\Program Files\Sensu\sensu-cli\bin\sensuctl\sensuctl.exe')
    end

    it 'adds `c:\Program Files\Sensu\sensu-cli\bin\sensuctl` to windows path' do
      expect(chef_run).to add_windows_path('c:\Program Files\Sensu\sensu-cli\bin\sensuctl')
    end

    it 'deletes the temporary directory `c:\sensutemp`' do
      expect(chef_run).to delete_directory('c:\sensutemp')
    end

    it 'configures the sensu cli' do
      expect(chef_run).to configure_sensu_ctl('default')
    end
  end
end

RSpec.describe 'sensu_test::ctl' do
  nix_platforms = {
    'ubuntu' => ['14.04', '16.04'],
    'centos' => '7.6',
  }
  win_platforms = {
    'windows' => %w(2012R2 2016 2019),
  }

  nix_platforms.each do |platform, versions|
    versions = versions.is_a?(String) ? [versions] : versions
    versions.each do |version|
      include_examples 'sensu_ctl', platform, version
    end
  end

  win_platforms.each do |platform, versions|
    versions = versions.is_a?(String) ? [versions] : versions
    versions.each do |version|
      include_examples 'sensu_ctl_win', platform, version
    end
  end
end
