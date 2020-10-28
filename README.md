# sensu-go

[![CI State](https://github.com/sensu/sensu-go-chef/workflows/ci/badge.svg)](https://github.com/sensu/sensu-go-chef/actions?query=workflow%3Aci)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/sensu/sensu-go-chef)](https://ci.appveyor.com/project/sensu/sensu-go-chef)
[![Build Status](https://travis-ci.org/sensu/sensu-go-chef.svg?branch=master)](https://travis-ci.org/sensu/sensu-go-chef)
[![Cookbook Version](https://img.shields.io/cookbook/v/sensu-go.svg)](https://supermarket.chef.io/cookbooks/sensu-go)
[![Community Slack](https://slack.sensu.io/badge.svg)](https://slack.sensu.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

**[Under Construction]** Chef Cookbook for The Sensu Go project

## Community

Sensu is discussed in many places but typically the best place to get adhoc general help is through or community slack in `#chef` channel.

## Scope

This Chef Cookbook is for installing & configuring Sensu 5.x
See the [sensu](https://supermarket.chef.io/cookbooks/sensu) cookbook if you wish to manage Sensu 1.x via Chef.

## Requirements

* Chef 15.0 or higher.
* Network accessible package repositories.

## Platform Support

The following platforms have been tested with Test Kitchen. It will most likely work on other platforms as well.

| Platform       | Supported Version |
|----------------|-------------------|
|                | 0.0.1             |
| amazonlinux    | X                 |
| amazonlinux-2  | X                 |
| centos-6       | X                 |
| centos-7       | X                 |
| fedora         | X                 |
| ubuntu-16.04   | X                 |
| ubuntu-18.04   | X                 |
| ubuntu-20.04   | X                 |
| windows-2012r2 | Agent Only        |
| windows-2016   | Agent Only        |
| windows-2019   | Agent Only        |

## Cookbook Dependencies

* [packagecloud](https://supermarket.chef.io/cookbooks/packagecloud)

## Usage

This is a library style cookbook that provides a set of resources to install and configure the Sensu 5.x environment in a composable way. It is intended to be used in your own wrapper cookbook suited to your specific needs. You can see a very simple example usage in the default recipe of the [sensu_test](https://github.com/sensu/sensu-go-chef/blob/master/test/cookbooks/sensu_test/recipes/default.rb) cookbook that is included in this repo. This recipe is used as part of integration testing.

* add `depends 'sensu-go'` to the metadata.rb for your cookbook.
* use the provided resources in your cookbook

```rb
sensu_backend 'default' do
  action [:install, :init]
end

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

* [sensu_backend](#sensu_backend): Install and configure the Sensu backend
* [sensu_agent](#sensu_agent): Install and configure the Sensu agent
* [sensu_ctl](#sensu_ctl): Install and configure the [sensuctl](https://docs.sensu.io/sensu-go/latest/sensuctl/reference/)
* [sensu_check](#sensu_check): Configure Sensu [checks](https://docs.sensu.io/sensu-go/latest/reference/checks/)
* [sensu_handler](#sensu_handler): Configure check [handlers](https://docs.sensu.io/sensu-go/latest/reference/handlers/)
* [sensu_hook](#sensu_hook): Configure Sensu [hooks](https://docs.sensu.io/sensu-go/latest/reference/hooks/) for use with checks
* [sensu_filter](#sensu_filter): Configure Sensu [filters](https://docs.sensu.io/sensu-go/latest/reference/filters/)
* [sensu_mutator](#sensu_mutator): Configure Sensu [mutators](https://docs.sensu.io/sensu-go/latest/reference/mutators/)
* [sensu_asset](#sensu_asset): Configure Sensu [assets](https://docs.sensu.io/sensu-go/latest/reference/assets/) for use with checks
* [sensu_namespace](#sensu_namespace): Configure Sensu [namespaces](https://docs.sensu.io/sensu-go/latest/reference/rbac/#namespaces)
* [sensu_entity](#sensu_entity): Configure Sensu [entities](https://docs.sensu.io/sensu-go/latest/reference/entities/)
* [sensu_role](#sensu_role): Configure Sensu RBAC [roles](https://docs.sensu.io/sensu-go/latest/reference/rbac/#roles-and-cluster-roles)
* [sensu_role_binding](#sensu_role_binding): Configure Sensu RBAC [role bindings](https://docs.sensu.io/sensu-go/latest/reference/rbac/#role-bindings-and-cluster-role-bindings)
* [sensu_cluster_role](#sensu_cluster_role): Configure Sensu RBAC [cluster roles](https://docs.sensu.io/sensu-go/latest/reference/rbac/#roles-and-cluster-roles)
* [sensu_cluster_role_binding](#sensu_cluster_role_binding): Configure Sensu RBAC [cluster role bindings](https://docs.sensu.io/sensu-go/latest/reference/rbac/#role-bindings-and-cluster-role-bindings)
* [sensu_postgres_config](#sensu_postgres_config): Configure Sensu to use [a Postgres DB](https://docs.sensu.io/sensu-go/latest/guides/scale-event-storage/#configure-postgres) for event storage
* [sensu_active_directory](#sensu_active_directory): Configure Sensu to use [Active Directory authentication](https://docs.sensu.io/sensu-go/latest/installation/auth/#ad-authentication)
* [sensu_auth_ldap](#sensu_auth_ldap): Configure Sensu to use [LDAP Authentication](https://docs.sensu.io/sensu-go/latest/operations/control-access/auth/#lightweight-directory-access-protocol-ldap-authentication)
* [sensu_auth_oidc](#sensu_auth_oidc): Configure Sensu to use [OIDC Authentication](https://docs.sensu.io/sensu-go/latest/operations/control-access/auth/#openid-connect-10-protocol-oidc-authentication)
* [sensu_secret](#sensu_secret): Configure Sensu [secrets](https://docs.sensu.io/sensu-go/latest/reference/secrets/)
* [sensu_secrets_provider](#sensu_secrets_provider): Configure Sensu [secrets providers](https://docs.sensu.io/sensu-go/latest/reference/secrets-providers/)
* [sensu_etcd_replicator](#sensu_etcd_replicator): Configure Sensu [etcd replication](https://docs.sensu.io/sensu-go/latest/operations/deploy-sensu/etcdreplicators/)
* [sensu_search](#sensu_search): Configure Sensu [saved searches](https://docs.sensu.io/sensu-go/latest/web-ui/searches-reference/)
* [sensu_global_config](#sensu_global_config): Configure Sensu [global Web UI settings](https://docs.sensu.io/sensu-go/latest/web-ui/webconfig-reference/)
* [sensu_tessen_config](#sensu_tessen_config): Configure Sensu [analytics preferences](https://docs.sensu.io/sensu-go/latest/operations/monitor-sensu/tessen/)
* [sensu_user](#sensu_user): Configure Sensu [non SSO managed RBAC users](https://docs.sensu.io/sensu-go/latest/operations/control-access/rbac/#users)

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
* `repo` which repo to pull package from, default: *sensu/stable*. If using private yum or apt repository, this is the baseurl/uri.
* `config_home` where to store the generated object definitions, default: */etc/sensu*
* `config` a hash of configuration, default: *{ 'state-dir': '/var/lib/sensu/sensu-backend'}*
* `distribution` possible values: commercial, source. Requires a valid yum or apt repository for installation. default: commercial
* `gpgkey` To be used with a package built from source. The GPG key for the package.
* `username` the username to initialize the backend with
* `password` the password to initialize the backend with

#### Examples

```rb
sensu_backend 'default'
```

For using packages built from source:

```
sensu_backend 'default' do
  distribution 'source'
  repo 'https://my-custom-repo.com/yum/$releasever/$basearch/'
end
```

Optionally pass configuration values for the backend:

##### (insecure example, don't really do this)

```rb
sensu_backend 'default' do
  repo 'sensu/stable'
  config({'state-dir' => '/var/lib/sensu/sensu-backend',
          'trusted-ca-file' => "/some/local/path.pem",
          'insecure-skip-tls-verify' => true})
end
```

### sensu_agent

The sensu agent resource will install and configure the agent. As of Sensu Go 6.0.0, it is no longer possible to update an existing agent configuration with this resource, and an agent entity should be made via [sensu_entity](#sensu_entity).
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

##### (insecure example, don't really do this)

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
* `command` **required** the check command to execute
* `cron` a schedule for the check, in cron format or a [predefined schedule](https://pkg.go.dev/github.com/robfig/cron#hdr-Predefined_schedules)
* `handlers` an array of handlers to run in response to the check, default: *[]*
* `high_flap_threshold` The flap detection high threshold, in percent
* `interval` The frequency in seconds the check is executed.
* `low_flap_threshold` The flap detection low threshold, in percent
* `namespace` the Sensu RBAC namespace that this check belongs to, default: *default*
* `proxy_entity_name` Used to create a proxy entity for an external resource
* `proxy_requests`  A [Sensu Proxy Request](https://docs.sensu.io/sensu-go/latest/reference/checks/#proxy-requests-attributes), representing Sensu entity attributes to match entities in the registry.
* `publish` If check requests are published for the check
* `round_robin` If the check should be executed in a [round robin fashion](https://docs.sensu.io/sensu-go/latest/reference/checks/#check-specification)
* `runtime_assets` An array of [Sensu assets](https://docs.sensu.io/sensu-go/latest/reference/assets/) required at runtime for the execution of the `command`
* `secrets` An array of hashes of name/secret pairs to use with command execution
* `stdin` If the Sensu agent writes JSON serialized entity and check data to the command process' STDIN
* `subscriptions` **required** an array of Sensu entity subscriptions that check requests will be sent to
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
  action :create
end


# Since this is a ruby based script, the check below defines two runtime_assets.
# One is the ruby-runtime asset, the other is the actual disk usage asset
sensu_check 'disk' do
  command 'check-disk-usage.rb -t xfs -w 95 -c 99'
  interval 60
  subscriptions %w(linux)
  handlers %w(pagerduty splunk)
  publish true
  ttl 100
  runtime_assets ['sensu-ruby-runtime', 'sensu-plugins-disk-checks']
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
* `namespace` the Sensu RBAC namespace that this check belongs to, default: *default*
* `runtime_assets` An array of [Sensu assets](https://docs.sensu.io/sensu-go/latest/reference/assets/) required at runtime for the execution of the `command`
* `secrets` an array of hashes of name/secret pairs to use with command execution
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
* `namespace` the Sensu RBAC namespace that this check belongs to, default: *default*
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
* `namespace` the Sensu RBAC namespace that this check belongs to, default: *default*
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
* `namespace` the Sensu RBAC namespace that this check belongs to, default: *default*
* `secrets` an array of hashes of name/secret pairs to use with command execution
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
* `namespace` the Sensu RBAC namespace that this check belongs to, default: *default*
* `builds` List, defines multiple artifacts that provide the named asset.
* `headers` Optional HTTP headers to apply to dynamic runtime asset retrieval

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

An entity is a representation of anything that needs to be monitored. From Sensu Go 6.0.0 onward, updates of an existing agent entity's subscriptions, labels, annotations, and attributes should be done via this resource, as updating via `sensu_agent` will be ignored.

#### Properties

* `entity_class` **required** the entity type, should be either `agent` or `proxy`.
* `deregister` Whether or not the entity should be removed from Sensu once the Sensu agent process's keepalive dies. Not needed for proxy entities.
* `deregistration` Hash of handlers for use when the entity is deregistered. Not needed for proxy entities.
* `namespace` the Sensu RBAC namespace that this check belongs to, default: *default*
* `redact` List of items to redact from log messages and dashboard. If a value is provided, it overwrites the default list of items to be redacted.
* `sensu_agent_version` Version of the agent entity running on the machine. Not needed for proxy entities.
* `subscriptions` An array of subscriptions. If no subscriptions are provided, it defaults to an entity-specific subscription list: `[entity:{ID}]`.
* `system` A hash of system information about the entity. A full list of attributes that can be used [can be found here](https://docs.sensu.io/sensu-go/latest/reference/entities/#system-attributes).
* `user` Sensu RBAC username used by the entity.

#### Examples

This example assumes that you've designed your proxy check to look for subscriptions (e.g., "entity.subscriptions.indexOf('hypervisor') >= 0" for the `proxy_requests`' `entity_attributes`).

```rb
sensu_entity 'example-hypervisor-entity' do
  entity_class 'proxy'
  subscriptions ['hypervisor']
  redact ['snmp_community_string']
  system(
    'hostname': 'example-hypervisor',
    'platform': 'Citrix Hypervisor',
    'platform_version': '8.1.0',
    'network': {
      'interfaces': [
        {
          'name': 'lo',
          'addresses': ['127.0.0.1/8'],
        },
        {
          'name': 'xapi0',
          'mac': '52:54:00:20:1b:3c',
          'addresses': ['172.0.1.72/24'],
        },
      ],
    },
  )
end
```

This example provides a proxy check for the label where `proxy_requests` `entity_attributes` matches `"entity.labels.proxy_type == 'website'"`. You must define both the entity and the check in your chef recipe.

Define the entity resource:

```rb
sensu_entity 'example-website-entity' do
  entity_class 'proxy'
  labels (
    'proxy_type': 'website',
    'url': 'https://my-website-url.com'
  )
end
```

And define the corresponding proxy check resource:

``` rb
sensu_check 'proxy_check_proxy_requests' do
  proxy_entity_name 'example-website-entity'
  proxy_requests(entity_attributes: [ "entity.labels.proxy_type == 'website'"])
  subscriptions %w(proxy)
  handlers %w(pagerduty email)
  command 'http_check.sh {{ .labels.url }}'
  interval 60
  publish true
  action :create
end
```

Note that this check uses [token substitution](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/checks/#check-token-substitution) so the command must be in single quotes.

Consult the [proxy check](https://docs.sensu.io/sensu-go/latest/observability-pipeline/observe-schedule/checks/#proxy-checks) section of the checks reference documentation for further details.

### sensu_role

The combination of Roles and RoleBindings grant users and groups permissions to resources within a namespace. Roles describe which resources and verbs a subject has access to.

#### Properties

* `rules` **required** an array of hashes, describing permissions granted by the role. See [Role and Cluster Role Rule attribute specification](https://docs.sensu.io/sensu-go/latest/reference/rbac/#rule-attributes) for details.

### sensu_role_binding

The combination of Roles and RoleBindings grant users and groups permissions to resources within a namespace. RoleBindings describe the association of a role with one or more subjects.

#### Properties

* `role_name` **required** the name of the role
* `role_type` **required** the role type, either `Role` or `ClusterRole`
* `subjects` **required** an array of hashes, each describing the `name` and `type` of a subject which is granted the permissions described by the named role.

See [Role binding and Cluster Role binding specification](https://docs.sensu.io/sensu-go/latest/reference/rbac/#role-binding-and-cluster-role-binding-specification) for additional details.

### sensu_cluster_role

The combination of ClusterRoles and ClusterRoleBindings grant users and groups permissions to resources across all namespaces. ClusterRoles describe which resources and verbs a subject has access to.

#### Properties

* `rules` **required** an array of hashes, describing permissions granted by the role. See [Role and Cluster Role Rule attribute specification](https://docs.sensu.io/sensu-go/latest/reference/rbac/#rule-attributes) for details.

### sensu_cluster_role_binding

The combination of ClusterRoles and ClusterRoleBindings grant users and groups permissions to resources within a namespace. ClusterRoleBindings describe the association of a role with one or more subjects.

#### Properties

* `role_name` **required** the name of the role
* `role_type` **required** the role type, either `Role` or `ClusterRole`
* `subjects` **required** an array of hashes, each describing the `name` and `type` of a subject which is granted the permissions described by the named role.

### sensu_postgres_config

Configure Sensu to store events in a [PostgreSQL](https://www.postgresql.org/) database.

#### Properties

* `dsn` **required** A string specifying the data source names as a URL or PostgreSQL connection string.
* `pool_size` An integer value for the maximum number of PostgreSQL connections to maintain.

See [PostgreSQL docs](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING) for more information about connection strings.

#### Examples

```rb
sensu_postgres_config 'default' do
    dsn "postgresql://sensu:pgtesting123@127.0.0.1:5432/sensu_events?sslmode=disable"
    pool_size 10
end
```

### sensu_active_directory

An active directory configuration to be applied to Sensu Go (commercial feature).

#### Properties

* `groups_prefix` Prefix for groups to include.
* `username_prefix` Prefix for users to include.
* `servers` **required** An array of active directory servers to connect to, including all of their properties.

#### Examples

```rb
sensu_active_directory 'active_directory' do
  servers [{
    'host': '127.0.0.1',
    'group_search': {
      'base_dn': 'dc=acme,dc=org',
    },
    'user_search': {
      'base_dn': 'dc=acme,dc=org',
    },
  }]
end
```

### sensu_auth_oidc

An OIDC  configuration applied to Sensu Go (commercial feature). Configuring OIDC is beyond the scope of this document, consult the sensu documentation for [OpenID Connect authentication](https://docs.sensu.io/sensu-go/latest/operations/control-access/auth/#openid-connect-10-protocol-oidc-authentication) and for [Registering an OIDC application](https://docs.sensu.io/sensu-go/latest/operations/control-access/auth/#register-an-oidc-application)

* `additional_scopes` Scopes to include in the claims, in addition to the default `openid` scope.
* `client_id` **required**
* `client_secret` **required** The OIDC provider Client Secret. This value should be dynamically retrieved from a secret store such as chef-vault
* `disable_offline_access`
* `redirect_uri`
* `server` **required** The location of the OIDC server you wish to authenticate against.
* `groups_claim`
* `groups_prefix`
* `username_prefix`
* `username_claim`
* `resource_type`

#### Examples

``` rb
sensu_auth_oidc 'fake_okta' do
  additional_scopes ["groups", "email"]
  client_id "a8e43af034e7f2608780"
  # Demo only! The client secret value should come from somewhere like chef-vault
  client_secret "b63968394be6ed2edb61c93847ee792f31bf6216"
  redirect_uri "http://sensu-backend.example.com:8080/api/enterprise/authentication/v2/oidc/callback"
  server "https://oidc.example.com:9031"
end
```

### sensu_auth_ldap

An ldap configuration to be applied to Sensu Go (commercial feature).

#### Properties

* `groups_prefix` Prefix for groups to include.
* `username_prefix` Prefix for users to include.
* `servers` **required** An array of ldap servers to connect to, including all of their properties as hashes. See [LDAP authentication](https://docs.sensu.io/sensu-go/latest/operations/control-access/auth/#lightweight-directory-access-protocol-ldap-authentication)

#### Examples

```rb
sensu_auth_ldap 'openldap' do
  servers [{
    'host': '127.0.0.1',
    'group_search': {
      'base_dn': 'dc=acme,dc=org',
      'attribute': 'member'
      'object_class': 'groupOfNames'
    },
    'user_search': {
      'base_dn': 'dc=acme,dc=org',
      'attribute': 'uid',
      'name_attribute': 'cn',
      'object_class': 'person'
    },
  }]
end
```

### sensu_secret

Create a secret that Sensu can grab from a secret provider so that sensitive information is not exposed (commercial feature).

#### Properties

* `id` **required** The key to use to retrive the secret. For the Env secrets provider, this is the environment variable. For the Vault secrets provider, this is the path and key in the form of `secret/path#key`. Currently, the Vault secrets provider does not support any base engine paths other than "secret/" for v2 K/V secrets engine.
* `namespace` the Sensu RBAC namespace that this check belongs to, default: *default*
* `secrets_provider` **required** Name of the provider, all in lowercase, ex: `'env'`, `'vault'`

#### Examples

Environment secret referencing the environment variable `CONSUL_TOKEN` on the backend server:

```rb
sensu_secret 'sensu-consul-token' do
  id 'CONSUL_TOKEN'
  secrets_provider 'env'
end
```

Vault secret referencing the key `token` at the path `secret/consul`:

```rb
sensu_secret 'sensu-consul-token' do
  id 'secret/consul#token'
  secrets_provider 'vault'
end
```

### sensu_secrets_provider

Create a secret provider for Sensu to connect to for secrets (commercial feature). Currently supports only Vault integration or Sensu Go's built-in secrets provider.

Either a token or a TLS hash must be provided.

#### Properties

* `address` **required** Vault server address.
* `max_retries` Maximum number of times to retry connecting to the Vault provider.
* `provider_type` Secret provider to use. Default: `'Env'`
* `rate_limiter` Hash of rate and burst limits for the Vault API.
* `timeout` Connection timeout for provider.
* `tls` Hash of certificate information required to access Vault.
* `token` Vault token to use for authentication.
* `version` Version of the [Vault KV secrets engine](https://www.vaultproject.io/docs/secrets/kv) you're trying to access. Default: `'v2'`

#### Examples

Minimal with token:

```rb
sensu_secrets_provider 'vault' do
  address 'https://vaultserver.example.com:8200'
end
  provider_type 'VaultProvider'
  token 'yourVaultToken'
```

Complete with TLS:

```rb
sensu_secrets_provider 'vault' do
  address 'https://vaultserver.example.com:8200'
  max_retries 2
  provider_type 'VaultProvider'
  rate_limiter(
    'limit': 10,
    'burst': 100
  )
  tls('ca_cert': '/path/to/your/ca.pem',
      'client_cert': '/path/to/backend/pem/for/vault.pem',
      'client_key': '/path/to/backend/key/for/vault.pem',
      'cname': 'sensu-backend.example.com'
     )
  timeout '60s'
  version 'v2'
end
```

### sensu_etcd_replicator

Etcd replicators allow you to manage RBAC resources in one place and mirror the changes to follower clusters. This resource allows you to set up etcd mirrors for one-way key replication (commercial feature).

#### Properties

* `ca_cert` Path to an the PEM-format CA certificate to use for TLS client authentication. *Required if using default transport security*
* `cert` Path to the PEM-format certificate to use for TLS client authentication. *Required if using default transport security*
* `key` Path to the PEM-format key file associated with the cert to use for TLS client authentication. *Required if using default transport security*
* `insecure` Set to true to disable transport security. *Not Recommended*. Default: `false`
* `url` Destination cluster URL. Use comma separated list in single quotes for more than one.
* `api_version` API version of the resource to replicate.
* `resource` Name of the resource to replicate.
* `namespace` Namespace to replicate or all namespaces for a given resource type if not set.
* `replication_interval_seconds` Interval in seconds for replication.

#### Examples

``` rb
sensu_etcd_replicator 'insecure_role_replicator' do
  insecure true # NOTE: Disable transport security with care.
  url 'http://127.0.0.1:2379'
  resource 'Role'
end

sensu_etcd_replicator 'role_replicator' do
  cert '/etc/ssl/fake.pem'
  key '/etc/ssl/fake.key'
  url 'http://127.0.0.1:2379'
  resource 'Role'
end

sensu_etcd_replicator 'role_binding_replicator' do
  cert '/etc/ssl/fake.pem'
  key '/etc/ssl/fake.key'
  url 'http://127.0.0.1:2379'
  resource 'RoleBinding'
end
```

### sensu_search

Create a save search that can be used in the Sensu web interface (commercial feature).

#### Properties

* `namespace` namespace for the save search
* `parameters` **required** parameters the search will apply
* `resource`  **required** fully qualified name of the resource

#### Examples

``` rb
sensu_search 'check-config' do
  parameters [
      "published:true",
      "subscription:linux",
      "labelSelector: region == \"us-west-1\""
  ]
  resource 'core.v2/CheckConfig'
end
```

### sensu_global_config

Web UI configuration allows you to define certain display options for the Sensu web UI, such as which web UI theme to use, the number of items to list on each page, and which URLs and linked images to expand. You can define a single custom web UI configuration to federate to all, some, or only one of your clusters (commercial feature).

#### Properties

* `always_show_local_cluster` Display the current cluster in federated environments
* `default_preferences` Global defaults for page size and theme
* `link_policy` Policy for what domains are valid and invalid targets

#### Examples

``` rb
sensu_global_config 'custom-web-ui' do
  default_preferences(page_size: 50,
                      theme: "deuteranopia")
  link_policy(allow_list: true,
              urls: [
                "https://example.com",
                "steamapp://34234234",
                "//google.com",
                "//*.google.com",
                "//bob.local"
              ])
end
```

### sensu_tessen_config

Tessen sends anonymized data about Sensu instances to Sensu Inc., including the version, cluster size, number of events processed, and number of resources created. This resource allows users to control their preference for cluster analytics collection.

This does not affect licensed Sensu instances since Tessen is enabled by default and required in those cases.

#### Properties

* `opt_out` Set to `true` to opt out of default analytics collection

### Examples

``` rb
sensu_tessen_config 'default' do
  opt_out true
end
```

### sensu_user

Manage non SSO sensu users. This resource requires a bcrypt password hash, you can use [`sensuctl user hash-password`](https://docs.sensu.io/sensu-go/latest/sensuctl/#generate-a-password-hash) to generate one.

#### Properties

* `username` String, username to manage.
* `password_hash` **required**, String.
* `groups` Array of [RBAC groups](https://docs.sensu.io/sensu-go/latest/operations/control-access/rbac/#groups) for the user
* `disabled` enable or disable a user

#### Examples

``` rb
# Disable someone who had their password exposed
sensu_user 'doofus' do
  password_hash '$2y$12$OrEQ61blxyTFi3PJHeJ94ej/Z857eSAnAdlSD4Kn7ywItTLrzTqVy'
  groups %w(view admin managers)
  disabled true
end

# Add a user with only view rights.
sensu_user 'reinstated' do
  password_hash '$2y$12$yga83H/KqKFKDYnLogQ6CeN3xrFmhVwMdVkh.hRPX/BhF2NJfYq8O'
  groups %w(view)
end
```

## License & Authors

If you would like to see the detailed LICENSE click [here](./LICENSE).

* Author:: Sensu <support@sensuapp.com>

```text
Copyright (c) 2020 Sensu

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
