RSpec.shared_context 'ubuntu-14.04' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(
      os: 'linux',
      platform: 'ubuntu',
      version: '14.04',
      file_cache_path: '/var/chef/cache'
    ).converge(described_recipe)
  end
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
end
