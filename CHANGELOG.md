# Change Log

This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format located [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md)

## [Unreleased]
- Updated the attributes for `agent` and `ctl` to version `6.1.0`. (@derekgroh)

## [1.1.0] - 2020-09-27
### Added
 - The following resources, `sensu_check`, `sensu_entity`, `sensu_filter`, `sensu_handler`, `sensu_hook`, `sensu_mutator`, and `sensu_secret` now expose a `namespace` attribute for controlling where the resource is created. Default is the `default` namespace. @joe-armstrong)
 - Minor README change for Sensu 6.0.0 handling of agent configs. (@kovukono)

## [1.0.0] - 2020-07-24

### Breaking Changes
- `sensu_check` now does not provide defaults for `command` and `subscriptions`, and they must be required as per the upstream specs. (@kovukono)
- declare chef supported versions to use match current chef support (15+) (@majormoses)

### Fixed
- Chef 16+ support (@kovukono)
- `sensu_entity` support for missing attributes (@kovukono)

### Added
- `sensu_active_directory` resource for active directory integration. (@kovukono)
- `sensu_secrets_provider` and `sensu_secret` resource for Vault integration, along with secret support for checks, handlers, and mutators. (@kovukono)
- `sensu_asset` now exposes a `namespace` attribute for controlling where the asset is created, by default it will use `default`. Default is the `default` namespace. @joe-armstrong)
- `sensu_asset` now supports multi-built assets using the `builds` key and accepts an array of hashes for each filter. By default no filters are passed. (@cwjohnston)
- all of the following resources: `asset`, `check`, `filter`, `handler`, and `mutator` have had new aliases added to the providers with an optional namespace to ease migration issues where a resource exists in both `sensu` and `sensu-go` the generic schema is `sensu_go_$COMPONENT`. For example `sensu_check` can be referenced also via `sensu_go_check`. (@majoemoses)

## [0.3.0] - 2020-05-13
### Fixed
- agent service will restart when its config changes (@kovukono)

### Added
- `sensu-backend` action :init adding returns to account for possible return codes.  exit code 3 is returned when already init.  This allows chef-client runs to not fail when running idempotently. (@tarcinil)
- `sensu-backend` now supports specifying an apt or yum repository for packages built from source. (@kovukono)

## [0.2.0] - 2020-01-05
### Breaking Changes

- `sensu-backend` property: `config` Readme incorrectly documented the wrong (@tmonk42)
  path. Called out as a breaking change in case anyone had begun using the incorrect setting but as this has not been released it will be versioned as a patch. (@tmonk42) - #66

### Added

- `filters` resource now supports `runtime_assets` being passed (@majormoses)
- Added support for `postgres_config` resource (@cwjohnston) - #70
- Added support for `role`, `role_binding`, `cluster_role` and `cluster_role_binding` resources (@cwjohnston) - #71
- Added init action to sensu-backend to allow functionality added in 5.16.0 (@kovukono) - #77

### Changed

- Refactored resource helpers to reduce duplication. (@cwjohnston) - #72

## [0.1.0] - 2019-09-16

### Added

- Most resources now support metadata specific properties (@webframp)
- add `sensu_hook` resource (@derekgroh)
- add `debug` option for `sensu_ctl` resource to help debug (@majormoses)
- add support for sensu-go-agent on windows platform (@derekgroh)
- fix symbols in annotations and labels (@scalp42)
- add sensu_ctl resource for windows platforms (@derekgroh) - #59

### Changed

- sensuctl cli args for asset updates now uses `--namespace`
- sensuctl cli args are escaped properly (@beeerd)
- sensuctl cli commands are marked sensitive by default (@beeerd)

### Breaking Changes

- Use stable package channels (@webframp)
- Temporarily remove Debian support until stable packages are available (@webframp)
- `sensu_organization` resource removed to match upstream (@webframp)
- Switched to beta package repository as default (@webframp)
- `sensu_environment` is now `sensu_namespace` (@webframp)
- `extended_attributes` property renamed to `annotations` as part of metadata (@webframp)
- Filter `statements` property renamed to `expressions` (@webframp)
- Entity `class` property renamed to `entity_class`

## [0.0.3] - 2018-09-12

### Added

- new `sensu_entity` resource (@mercul3s)
- new `sensu_organization` resource (@mercul3s)
- new `sensu_environment` resource (@mercul3s)

## [0.0.2] - 2018-08-29

### Added

- Adding `output_metric` settings to the `sensu_check` resource

## [0.0.1]

### Added

- new `.editorconfig` to help users who have editors that support [editor config](https://editorconfig.org/)
- new PR and issue templates (@majormoses)
- links to community slack (@majormoses)
- new `sensu_mutator` resource (@webframp)
- new `sensu_filter` resource (@webframp)
- new `sensu_handler` resource (@webframp)
- new `sensu_check` resource (@webframp)
- new `sensu_ctl` resource to install and configure (@webframp)
- Created repo with initial commit (@mbbroberg)
- Added CODEOWNERS (@majormoses)
- Added skel files from Chef Partners cookbook generator (@thomasriley)

### Changed

- Updated contributing instruction (@majormoses)
- use `@sensu/chef-cookbooks` for `CODEOWNERS` rather than individual users now that there is a team to refer to instead (@majormoses)

### Fixed

- moved `CODEOWNERS` into the correct location (@majormoses)
- updated development dependencies (@majormoses)
- using a version of `'latest'` for backend and agent providers will now upgrade to the test version

<!-- prettier-ignore -->
[Unreleased]: https://github.com/sensu/sensu-go-chef/compare/1.1.0...HEAD
[1.1.0]: https://github.com/sensu/sensu-go-chef/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/sensu/sensu-go-chef/compare/0.3.0...1.0.0
[0.3.0]: https://github.com/sensu/sensu-go-chef/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/sensu/sensu-go-chef/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/sensu/sensu-go-chef/compare/0.0.3...0.1.0
[0.0.3]: https://github.com/sensu/sensu-go-chef/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu/sensu-go-chef/compare/0.0.1...0.0.2
[0.0.1]: https://github.com/sensu/sensu-go-chef/compare/37630d8624247f0e2dc41de8de8c2ccd29d55694...0.0.1
