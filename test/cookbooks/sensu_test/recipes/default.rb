sensu_backend 'default'

sensu_agent 'default'

sensu_ctl 'default' do
  action [:install, :configure]
end
