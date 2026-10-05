# Changelog

All notable changes to this module are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module uses [semantic versioning](https://semver.org/): a new major version means callers must change their code.

## [Unreleased]

## [1.0.0] - 2026-10-05

Initial release.

### Added

- An Elastic IP address for use in a VPC, allocated from Amazon's pool and associated with nothing.
- `Scope`, `Purpose`, `Environment` and `Name` tags from the `details` input, with `eip_target` to tell several addresses apart in the `Name` tag.
- `region`, to allocate the address in a Region other than the provider's.
- A `metadata` output with the address, its allocation ID and everything else the module created.
- Offline tests, and examples for one address and for several addresses in another Region.

[Unreleased]: https://github.com/AutomateTheCloud/terraform-aws-eip/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/AutomateTheCloud/terraform-aws-eip/releases/tag/v1.0.0
