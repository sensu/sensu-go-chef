sensu_ctl 'default' do
  action [:install, :configure]
  backend_url 'https://172.128.10.2'
end
