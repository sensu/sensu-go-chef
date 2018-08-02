sensu_backend 'default'

sensu_ctl 'default' do
  action [:install, :configure]
end

assets = data_bag_item('sensu', 'assets')
assets.each do |name, property|
  next if name == 'id'
  sensu_asset name do
    url property['url']
    sha512 property['sha512']
  end
end

sensu_handler 'cat' do
  type 'pipe'
  command 'cat'
end

sensu_check 'dummy-app-health' do
  runtime_assets %w(check-plugins)
  command 'check-http -u http://localhost:8080/healthz'
  subscriptions %w(dummy_app)
  interval 10
  handlers %w(cat)
  publish true
end

sensu_check 'dummy-app-prometheus' do
  runtime_assets %w(prometheus-collector)
  command 'sensu-prometheus-collector -exporter-url http://localhost:8080/metrics'
  subscriptions %w(dummy_app)
  interval 10
  handlers %w(cat)
  publish true
end
