RSpec.shared_context 'common_stubs' do
  assets_stub = {
    'sample-plugin' => {
      'url' => 'http://fake-plugin',
      'checksum' => '0xdeadbeef',
    },
  }

  before do
    stub_data_bag_item('sensu', 'assets').and_return(assets_stub)
    stub_command("((Get-Service SensuAgent).Name -eq \"SensuAgent\")") # rubocop:disable Style/StringLiterals
    stubs_for_provider('sensu_ctl[default]') do |provider|
      allow(provider).to receive_shell_out('sensuctl user list')
      allow(provider).to receive_shell_out('sensuctl version').and_return(double(run_command: nil, error!: nil, stdout: 'sensuctl version 0.0.0', stderr: '', exitstatus: 0, live_stream: '')) # Windows check if Sensuctl is installed
    end
    stub_command("Test-Path c:/sensutemp/sensu-go_6.1.0_windows_amd64.tar.gz").and_return(true) # rubocop:disable Style/StringLiterals
  end
end

RSpec.shared_context 'ubuntu-18.04' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(
      os: 'linux',
      platform: 'ubuntu',
      version: '18.04',
      file_cache_path: '/var/chef/cache'
    ).converge(described_recipe)
  end
  include_context 'common_stubs'
end

RSpec.shared_context 'ubuntu-20.04' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(
      os: 'linux',
      platform: 'ubuntu',
      version: '20.04',
      file_cache_path: '/var/chef/cache'
    ).converge(described_recipe)
  end
  include_context 'common_stubs'
end

RSpec.shared_context 'centos-7' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(
      os: 'linux',
      platform: 'centos',
      version: '7.8.2003',
      file_cache_path: '/var/chef/cache'
    ).converge(described_recipe)
  end
  include_context 'common_stubs'
end
