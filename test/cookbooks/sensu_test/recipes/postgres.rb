sensu_postgres_config 'sensu_pg' do
  dsn 'postgresql://sensu:pgtesting123@127.0.0.1:5432/sensu_events?sslmode=disable'
  pool_size 10
  action :create
end
