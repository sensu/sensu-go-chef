remote_file '/srv/dummy' do
  source 'https://github.com/portertech/dummy/releases/download/1.0.0/dummy'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

systemd_unit 'dummy.service' do
  content({Unit: {
            Description: 'Dummy',
            After: 'network.target',
          },
          Service: {
            Type: 'simple',
            ExecStart: '/srv/dummy',
            Restart: 'on-failure',
          },
          Install: {
            WantedBy: 'multi-user.target',
          }})
  action [:create, :start]
end
