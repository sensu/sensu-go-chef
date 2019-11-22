# sensu-go
[![Build Status](https://ci.appveyor.com/api/projects/status/github/sensu/sensu-go-chef)](https://ci.appveyor.com/project/sensu/sensu-go-chef)
[![Build Status](https://travis-ci.org/sensu/sensu-go-chef.svg?branch=master)](https://travis-ci.org/sensu/sensu-go-chef)
[![Cookbook Version](https://img.shields.io/cookbook/v/sensu-go.svg)](https://supermarket.chef.io/cookbooks/sensu-go)
[![Community Slack](https://slack.sensu.io/badge.svg)](https://slack.sensu.io/badge)


**[Under Construction]** Chef Cookbook for The Sensu Go project

### Community

Sensu is discussed in many places but typically the best place to get adhoc general help is through or community slack in `#chef` channel.

## Scope

This Chef Cookbook is for installing & configuring Sensu 5.x
See the [sensu](https://supermarket.chef.io/cookbooks/sensu) cookbook if you wish to manage Sensu 1.x via Chef.

## Requirements

* Chef 12.5 or higher.
* Network accessible package repositories.

## Platform Support
The following platforms have been tested with Test Kitchen. It will most likely work on other platforms as well.

| Platform | Supported Version|
|---------------|-------|
|               | 0.0.1 |
| centos-6      | X     |
| centos-7      | X     |
| fedora        | X     |
| ubuntu-14.04  | X     |
| ubuntu-16.04  | X     |
| windows-2012r2 | Agent Only |
| windows-2016 | Agent Only |
| windows-2019 | Agent Only |

## Cookbook Dependencies

* [packagecloud](https://supermarket.chef.io/cookbooks/packagecloud)

## Usage

This is a library style cookbook that provides a set of resources to install and configure the Sensu 5.x environment in a composable way. It is intended to be used in your own wrapper cookbook suited to your specific needs. You can see a very simple example usage in the default recipe of the [sensu_test](https://github.com/sensu/sensu-go-chef/blob/master/test/cookbooks/sensu_test/recipes/default.rb) cookbook that is included in this repo. This recipe is used as part of integration testing.

* add `depends 'sensu-go'` to the metadata.rb for your cookbook.
* use the provided resources in your cookbook

```rb
sensu_backend 'default'

sensu_agent 'default'

sensu_ctl 'default' do
  action [:install, :configure]
end

sensu_check 'cron' do
  command '/bin/true'
  cron '@hourly'
  subscriptions %w(dad_jokes production)
  handlers %w(pagerduty email)
  annotations(runbook: 'https://www.xkcd.com/378/')
  publish false
  ttl 100
  high_flap_threshold 60
  low_flap_threshold 20
  subdue(days: { all: [{ begin: '12:00 AM', end: '11:59 PM' },
                       { begin: '11:00 PM', end: '1:00 AM' }] })
  action :create
end

# data bag contains url, checksum for asssets
assets = data_bag_item('sensu', 'assets')
assets.each do |name, property|
  next if name == 'id'
  sensu_asset name do
    url property['url']
    sha512 property['checksum']
  end
end

sensu_handler 'slack' do
  type 'pipe'
  command 'handler-slack --webhook-url https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX --channel monitoring'
end

sensu_filter 'production_filter' do
  filter_action 'allow'
  expressions [
    "event.Entity.Environment == 'production'",
  ]
end

sensu_mutator 'example-mutator' do
  command 'example_mutator.rb'
  timeout 60
end
```

## Testing

For more details look at the [TESTING.md](./TESTING.md).

## Resource Overview
These resources primarily work by writing the Sensu 5.x object definitions to a local path and then using the sensuctl command line to reconfigure the definitions known to the sensu backend.

* `sensu_backend` install and configure the sensu backend
* `sensu_agent` install and configure the sensu agent
* `sensu_ctl` install and configure the [sensuctl](https://docs.sensu.io/sensu-go/latest/sensuctl/reference/)
* `sensu_check` configure sensu [checks](https://docs.sensu.io/sensu-go/latest/reference/checks/)
* `sensu_handler` configure check [handlers](https://docs.sensu.io/sensu-go/latest/reference/handlers/)
* `sensu_filter` configure sensu [filters](https://docs.sensu.io/sensu-go/latest/reference/filters/)
* `sensu_mutator` configure sensu [mutators](https://docs.sensu.io/sensu-go/latest/reference/mutators/)
* `sensu_asset` configure sensu [assets](https://docs.sensu.io/sensu-go/latest/reference/assets/)for use with checks
* `sensu_hook` configure sensu [hooks](https://docs.sensu.io/sensu-go/latest/reference/hooks/)for use with checks

## Resource Details

### Common properties
Sensu resources that support metadata attributes share these common properties:

* `namespace` the Sensu RBAC namespace that this check belongs to, default: *default*
* `labels` custom extended attributes to add to the check
* `annotations` custom extended attributes to add to the check

`name` metadata will be set automatically from the resource name

### sensu_backend
The sensu backend resource can configure the core sensu backend service.

#### Properties
* `version` which version to install, default: *latest*
* `repo` which repo to pull package from, default: *sensu/stable*
* `config_home` where to store the generated object definitions, default: */etc/sensu*
* `config` a hash of configuration, default: *{ 'state-dir': '/var/lib/sensu/sensu-backend'}*

#### Examples
```rb
sensu_backend 'default'
```
Optionally pass configuration values for the backend:

**(insecure example, don't really do this)**
```rb
sensu_backend 'default' do
  repo 'sensu/stable'
  config({'state-dir' => '/var/lib/sensu/sensu-backend',
          'trusted-ca-file' => "/some/local/path.pem",
          'insecure-skip-tls-verify' => true})
end
```
### sensu_agent
The sensu agent resource will install and configure the agent.
**NOTE:** windows agent install is pinned to version 5.10 until available in a consumable package format (likely chocolately)
#### Properties
* `version` which version to install, default: *latest*
* `repo` which repo to pull package from, default: *sensu/stable*
* `config_home` where to store the generated object definitions, default: */etc/sensu*
* `config` a hash of configuration

#### Examples
```rb
sensu_agent 'default'
```

**(insecure example, don't really do this)**

```rb
sensu_agent 'default' do
  config(
    "name": node['fqdn'],
    "namespace": "default",
    "backend-url": ["wss://sensu-backend.example.com:8081"],
    "insecure-skip-tls-verify": true,
    "subscriptions": ["centos", "haproxy"],
    "labels": {
      "app_id": "mycoolapp",
      "app_tier": "loadbalancer"
    },
    "annotations": {
      "color": "green"
    }
  )
end
```

### sensu_ctl
Installs and configures the sensuctl cli
#### Properties
* `version` which version to install, default: *latest*
* `repo` which repo to pull package from, default: *sensu/nightly*
* `username` username for connecting to the sensu backend
* `password` password for connecting to the sensu backend
* `backend_url` url for the sensu backend, default: `http://127.0.0.1:8080`
#### Examples
```rb
sensu_ctl 'default'
```
```rb
sensu_ctl 'default' do
  backend_url 'https://sensu.startup.horse'
end
```

### sensu_check
The sensu_check resource is used to define check objects.
#### Properties
* `config_home` default: */etc/sensu*
* `check_hooks` an array of hook name to run in response to the check
* `command` **required** the check command to execute, default: */bin/true*
* `cron` a schedule for the check, in cron format or a [predefined schedule](https://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules)
* `handlers` **required** an array of handlers to run in response to the check, default: *[]*
* `high_flap_threshold` The flap detection high threshold, in percent
* `interval` The frequency in seconds the check is executed.
* `low_flap_threshold` The flap detection low threshold, in percent
* `proxy_entity_name` Used to create a proxy entity for an external resource
* `proxy_requests`  A [Sensu Proxy Request](https://docs.sensu.io/sensu-go/latest/reference/checks/#proxy-requests-attributes), representing Sensu entity attributes to match entities in the registry.
* `publish` If check requests are published for the check
* `round_robin` If the check should be executed in a [round robin fashion](https://docs.sensu.io/sensu-go/latest/reference/checks/#check-specification)
* `runtime_assets` An array of [Sensu assets](https://docs.sensu.io/sensu-go/latest/reference/assets/) required at runtime for the execution of the `command`
* `stdin` If the Sensu agent writes JSON serialized entity and check data to the command process' STDIN
* `subdue` A [Sensu subdue](https://docs.sensu.io/sensu-go/latest/reference/checks/#subdue-attributes), which is a hash of days of the week
* `subscriptions` **required** an array of Sensu entity subscriptions that check requests will be sent to, default *[]*
* `timeout` The check execution duration timeout in seconds
* `ttl` The value in seconds until check results are considered stale
* `output_metric_format` (optional) the metric format that the output of this check conforms to
* `output_metric_handlers` (optional) an array of handlers for output metrics from this check

#### Examples
```rb
sensu_check 'cron' do
  command '/bin/true'
  cron '@hourly'
  subscriptions %w(dad_jokes)
  handlers %w(pagerduty email)
  annotations(runbook: 'https://www.xkcd.com/378/')
  publish false
  ttl 100
  high_flap_threshold 60
  low_flap_threshold 20
  subdue(days: { all: [{ begin: '12:00 AM', end: '11:59 PM' },
                       { begin: '11:00 PM', end: '1:00 AM' }] })
  action :create
end

```

### sensu_handler
#### Properties
* `command` the command to run *only allowd if type is pipe*
* `env_vars` an array of environment variables to use with command execution *only allowed if type is pipe*
* `filters` an array of Sensu event filter names to use
* `handlers` an array of Sensu event handler names to use for events
* `mutator` mutator to use to mutate event data for the handler
* `runtime_assets` An array of [Sensu assets](https://docs.sensu.io/sensu-go/latest/reference/assets/) required at runtime for the execution of the `command`
* `socket` the socket definition scope, used to configure the TCP/UDP handler socket
* `timeout` the handler execution duration timeout in seconds, only used with *pipe* and *tcp* types
* `type` **required** handler type, one of *pipe, tcp, udp* or *set*

#### Examples
```rb
sensu_handler 'tcp_handler' do
  type 'tcp'
  socket({host: '10.0.1.99',
          port: 4444
         })
  timeout 30
end
```
### sensu_hook
Used to define hooks for sensu checks
#### Properties
* `command` **required** command to be executed
* `timeout` duration timeout in seconds (hard stop)
* `stdin`  If the Sensu agent writes JSON serialized Sensu entity and check data to the command process’ STDIN. The command must expect the JSON data via STDIN, read it, and close STDIN. This attribute cannot be used with existing Sensu check plugins, nor Nagios plugins etc, as Sensu agent will wait indefinitely for the hook process to read and close STDIN

#### Examples
```rb
sensu_hook 'restart_nginx' do
  command 'sudo systemctl start nginx'
  timeout 60,
  stdin false
end
```

```rb
sensu_hook 'process_tree' do
  command 'ps aux'
  timeout 60,
  stdin false
end
```

### sensu_filter
Used to define filters for sensu checks
#### Properties
* `filter_action` **required** action to take with the event if the filter statements match. One of: `allow`, `deny`
* `expressions` **required** filter expressions to be compared with event data.
* `when` the [when definition scope](https://docs.sensu.io/sensu-go/latest/reference/filters/#when-attributes), used to determine when a filter is applied with time windows

#### Examples
```rb
sensu_filter 'production_filter' do
  filter_action 'allow'
  expressions [
    "event.Entity.Environment == 'production'",
  ]
end
```

```rb
sensu_filter 'state_change_only' do
  filter_action 'allow'
  expressions [
    "event.Check.Occurrences == 1"
  ]
end
```

### sensu_mutator
A handler can specify a mutator to transform event data. This resource can define named resources to be used by handlers.
#### Properties
* `command` **required** the command to run
* `env_vars` an array of environment variables to use with command execution
* `timeout` the execution duration timeout in seconds
#### Examples
The following defines a filter that uses a Sensu plugin called `example_mutator.rb` to modify event data prior to handling the event.

```rb
sensu_mutator 'example-mutator' do
  command 'example_mutator.rb'
  timeout 60
end
```
### sensu_asset
At runtime the agent can sequentially fetch assets and store them in its local cache but these must first be defined by name for the sensu backend.
#### Properties
* `filters` a set of filter criteria used by the agent to determine of the asset should be installed.
* `sha512` **required** the checksum of the asset.
* `url` **required** the URL location of the asset.

#### Examples
```rb
sensu_asset 'asset_example' do
  url 'http://example.com/asset/example.tar'
  sha512 '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b'
  filters [
    "System.OS==linux"
  ]
end
```

### sensu_namespace
A Namespace partitions resources within Sensu, this replaces organizations/environments. The resource name is the namespace name.
#### Examples
```rb
sensu_namespace 'example_namespace' do
  action :create
end
```

### sensu_entity
An entity is a representation of anything that needs to be monitored. It can be either an `agent` or a `proxy`.

#### Properties
* `subscriptions` An array of subscriptions. If no subscriptions are provided,
it defaults to an entity-specific subscription list: `[entity:{ID}]`.
* `entity_class` **required** the entity type, must be either `agent` or `proxy`.

#### Examples
```rb
sensu_entity 'example-entity' do
  subscriptions ['example-entity']
  entity_class 'proxy'
end
```

### sensu_postgres_config
Configure Sensu to store events in a [PostgreSQL](https://www.postgresql.org/) database.

#### Properties

* `dsn` A string specifying the data source names as a URL or PostgreSQL connection string.
* `pool_size` An integer value for the maximum number of PostgreSQL connections to maintain.

See [PostgreSQL docs](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING) for more information about connection strings.

#### Examples
```rb
sensu_postgres_config 'default' do
    dsn "postgresql://sensu:pgtesting123@127.0.0.1:5432/sensu_events?sslmode=disable"
    pool_size 10
end
```

## License & Authors

If you would like to see the detailed LICENSE click [here](./LICENSE).

- Author:: Sensu <support@sensuapp.com>

```text
Copyright (c) 2018 Sensu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
