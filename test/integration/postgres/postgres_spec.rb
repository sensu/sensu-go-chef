describe json('/etc/sensu/postgres_configs/sensu_pg.json') do
  its(%w(type)) { should eq 'PostgresConfig' }
  its(%w( metadata name)) { should eq 'sensu_pg' }
  its(%w(spec dsn)) { should eq 'postgresql://sensu:pgtesting123@127.0.0.1:5432/sensu_events?sslmode=disable' }
  its(%w(spec pool_size)) { should eq 10 }
end
