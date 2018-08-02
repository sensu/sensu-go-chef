sensu_backend 'default'

sensu_ctl 'default' do
  action [:install, :configure]
end

sensu_filter 'only_production' do
  filter_action 'allow'
  statements [
    "event.Entity.Environment == 'production'",
  ]
end

sensu_handler 'cat' do
  type 'pipe'
  command 'cat'
  filters %w(only_production)
end

sensu_check 'cron' do
  command '/bin/true'
  cron '* * * * *'
  subscriptions %w(production)
  handlers %w(cat)
  extended_attributes(runbook: 'https://www.xkcd.com/378/')
end
