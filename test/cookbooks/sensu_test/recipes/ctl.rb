sensu_ctl 'default' do
  action [:install, :configure]
  backend_url 'http://172.128.10.2:8080'
end
