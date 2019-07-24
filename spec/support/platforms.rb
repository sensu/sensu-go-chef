RSpec.shared_context 'common_stubs' do
  assets_stub = {
    'sample-plugin' => {
      'url' => 'http://fake-plugin',
      'checksum' => '0xdeadbeef',
    },
  }

  before do
    stub_data_bag_item('sensu', 'assets').and_return(assets_stub)
    # rubocop:disable Style/StringLiterals
    stub_command("((Get-Service SensuAgent).Name -eq \"SensuAgent\")")
  end
end

RSpec.shared_context 'ubuntu-14.04' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(
      os: 'linux',
      platform: 'ubuntu',
      version: '14.04',
      file_cache_path: '/var/chef/cache'
    ).converge(described_recipe)
  end
  include_context 'common_stubs'
end

RSpec.shared_context 'ubuntu-16.04' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(
      os: 'linux',
      platform: 'ubuntu',
      version: '16.04',
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
      version: '7.3.1611',
      file_cache_path: '/var/chef/cache'
    ).converge(described_recipe)
  end
  include_context 'common_stubs'
end
