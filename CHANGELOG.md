# Change Log

This project tries to follow [Semantic Versioning](http://semver.org/).

## [0.9.1] - 2018-11-13

### Fixed

- Lib: remove deprecated ssl directive

## [0.9.0] - 2018-11-13

### Changed

- Docker: upgrade to supported version of nginx (1.15.6)

## [0.8.1]

### Fixed

- Entrypoint: pass all parameters for first-time certificate creation.

## [0.8.0]

### Added

- Helper script: cert-renew.sh for online renewal
- Helper script: backends-reconfigure.sh for online reconfiguration of backends (online / offline)
- Entrypoint: cleanup and use library functions

### Changed

- Script: extracted most functions into shell libraries
- Script: wrote unit test for most shell library functions
