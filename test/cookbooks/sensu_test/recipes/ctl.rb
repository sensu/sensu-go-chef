sensu_ctl 'default' do
  action [:install, :configure]
  username 'guest'
  password 'i<3sensu'
  backend_url 'https://caviar.tf.sensu.io:8080/'
end
