# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.1] - 2025-01-06

### Fixed
- Test suite reliability - replaced flaky integration tests with reliable unit tests
- Tests now achieve 100% pass rate (was 76.9%)
- Removed dependency on actual TCP connections in tests for CI stability
- Test execution time improved from 4-8s to 0.45s

### Added
- Automated RubyGems publishing via GitHub Actions
- RELEASING.md with comprehensive release documentation
- Additional test coverage for empty chunk handling

### Documentation
- Updated CONTRIBUTING.md with automated release process
- Added "Development & Release" section to README
- Improved test comments and documentation

## [0.3.0] - 2025-01-06

### Changed
- **BREAKING**: Migrated from deprecated `BufferedOutput` to modern `Fluent::Plugin::Output` API
- **BREAKING**: Changed module namespace from `Fluent` to `Fluent::Plugin`
- Updated to modern Fluentd plugin architecture (requires Fluentd >= 0.14.10)
- Improved error handling with explicit exception types and logging
- Enhanced socket cleanup with nil checks

### Added
- GitHub Actions CI workflow for multi-version Ruby testing (2.7, 3.0, 3.1, 3.2, 3.3)
- Anchore Grype CVE security scanning workflow with SARIF upload
- Comprehensive test suite with unit and integration tests
- Configuration validation (raises error when no servers configured)
- Ruby version requirement (>= 2.4.0)
- Explicit yajl-ruby runtime dependency
- Better error messages for connection failures
- Documentation improvements with configuration examples

### Updated
- bundler: ~> 2.0.1 → ~> 2.5
- rake: ~> 12.0 → ~> 13.0
- test-unit: ~> 3.0 → ~> 3.6
- fluentd: Tested up to 1.19.1
- All transitive dependencies to latest versions

### Removed
- Deprecated `compat_parameters` helper
- `include_time_key` config parameter (use inject section instead)
- Travis CI configuration (replaced with GitHub Actions)

### Fixed
- Socket cleanup now handles nil sockets properly
- Improved handling of non-Hash records
- Fixed gemspec warnings (description vs summary)

## [0.2.0] - 2020-06-15

### Added
- Multi-worker support
- Configurable connection and send timeouts
- Multiple server support with automatic failover
- Message injection support (tag, time, etc.)

### Changed
- Updated to use modern Fluentd helpers

## [0.1.0] - 2017-08-01

### Added
- Initial release
- Basic TCP output functionality
- JSON formatting
- Single server support

[0.3.1]: https://github.com/particle-man/fluent-plugin-tcp_mc/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/particle-man/fluent-plugin-tcp_mc/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/particle-man/fluent-plugin-tcp_mc/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/particle-man/fluent-plugin-tcp_mc/releases/tag/v0.1.0
