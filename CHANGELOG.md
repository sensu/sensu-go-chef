# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format located [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md)

## [Unreleased]
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
- Adding `output_metric` settings to the `sensu_check` resource
- Updated contributing instruction (@majormoses)
- use `@sensu/chef-cookbooks` for `CODEOWNERS` rather than individual users now that there is a team to refer to instead (@majormoses)

### Fixed
- moved `CODEOWNERS` into the correct location (@majormoses)
- updated development dependencies (@majormoses)
- using a version of `'latest'` for backend and agent providers will now upgrade to the test version

[Unreleased]: https://github.com/sensu/sensu-go-chef/compare/37630d8624247f0e2dc41de8de8c2ccd29d55694...HEAD
