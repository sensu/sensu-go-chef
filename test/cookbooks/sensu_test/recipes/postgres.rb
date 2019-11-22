postgresql_server_install 'default' do
    action [:install, :create]
end

# Using this to generate a service resource to control
find_resource(:service, 'postgresql') do
    extend PostgresqlCookbook::Helpers
    service_name lazy { platform_service_name }
    supports restart: true, status: true, reload: true
    action [:enable, :start]
end

postgresql_server_conf 'PostgreSQL Config' do
    notifies :reload, 'service[postgresql]'
end

postgresql_user 'sensu' do
    password 'pgtesting123'
end

postgresql_ident 'Map sensu to sensu' do
    comment 'Sensu'
    mapname 'sensu'
    system_user 'sensu'
    pg_user 'sensu'
end

postgresql_database 'sensu_events' do
    owner 'sensu'
end

postgresql_access 'sensu_user' do
    comment 'Sensu user access'
    access_type 'host'
    access_db 'sensu_events'
    access_user 'sensu'
    access_addr '127.0.0.1/32'
    access_method 'md5'
end

sensu_postgres_config 'sensu_pg' do
    dsn "postgresql://sensu:pgtesting123@127.0.0.1:5432/sensu_events?sslmode=disable"
    pool_size 10
    action :create
end
