sensu_backend 'default'

sensu_agent 'default'

sensu_ctl 'default' do
  action [:install, :configure]
end

sensu_check 'cron' do
  command '/bin/true'
  cron '@hourly'
  subscriptions %w(dad_jokes production)
  handlers %w(pagerduty email)
  extended_attributes(runbook: 'https://www.xkcd.com/378/')
  publish false
  ttl 100
  high_flap_threshold 60
  low_flap_threshold 20
  subdue(days: { all: [{ begin: '12:00 AM', end: '11:59 PM' },
                       { begin: '11:00 PM', end: '1:00 AM' }] })
  action :create
end

assets = data_bag_item('sensu', 'assets')
assets.each do |name, property|
  next if name == 'id'
  sensu_asset name do
    url property['url']
    sha512 property['checksum']
  end
end
