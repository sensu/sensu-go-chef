backend_ip = search(:node, 'recipes:sensu_examples\:\:backend')[0]['ipaddress']

subscriptions = node['recipes'].map { |recipe|
  recipe.gsub(/^.*::/, '')
} + node['roles'] + ['all']

sensu_agent 'default' do
  config({
           'id' => node['hostname'],
           'organization' => 'default',
           'environment' => 'default',
           'backend-url' => ["ws://#{backend_ip}:8081"],
           'subscriptions' => subscriptions
         })
end

sensu_ctl 'default' do
  backend_url "http://#{backend_ip}:8080"
  action [:install, :configure]
end
