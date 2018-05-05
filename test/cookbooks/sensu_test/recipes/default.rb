sensu_backend 'default'

sensu_agent 'default'

sensu_ctl 'default' do
  action [:install, :configure]
end

sensu_check 'cron' do
  command '/bin/true'
  subscriptions ['dad_jokes']
  action :create
end
