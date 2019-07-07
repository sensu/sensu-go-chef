# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format located [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md)

## [Unreleased]
### Added
- Most resources now support metadata specific properties (@webframp)
- add `sensu_hook` resource (@derekgroh)
- add `debug` option for `sensu_ctl` resource to help debug (@majormoses)
- fix symbols in annotations and labels (@scalp42)

### Changed
- sensuctl cli args for asset updates now uses `--namespace`

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

[Unreleased]: https://github.com/sensu/sensu-go-chef/compare/0.0.3...HEAD
[0.0.3]: https://github.com/sensu/sensu-go-chef/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu/sensu-go-chef/compare/0.0.1...0.0.2
[0.0.1]: https://github.com/sensu/sensu-go-chef/compare/37630d8624247f0e2dc41de8de8c2ccd29d55694...0.0.1
