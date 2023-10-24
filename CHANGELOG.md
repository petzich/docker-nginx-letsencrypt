# Change Log

This project tries to follow [Semantic Versioning](http://semver.org/).

## [0.9.13] - 2023-10-24

- Docker: upgrade nginx (1.23.2 -> 1.25.2)

## [0.9.12] - 2022-10-30

### Changed

- Docker: upgrade nginx (1.20.1 -> 1.23.2)

## [0.9.11] - 2021-06-25

### Changed

- Docker: upgrade nginx (1.19.7 -> 1.20.1)

## [0.9.10] - 2021-06-25

### Fixed

- Lib: actually set the value for worker connections

## [0.9.9] - 2021-02-21

### Fixed

- Tests: failing tests due to new newlines

## [0.9.8] - 2021-02-21

### Changed

- Docker: upgrade alpine (1.17.8 -> 1.19.6)

## [0.9.7] - 2020-02-04

### Changed

- Docker: upgrade nginx (1.15.12 -> 1.17.8)

## [0.9.6] - 2019-05-03

### Fixed

- Lib: use envsubst to process environment variable replacements

## [0.9.5] - 2019-04-20

### Changed

- Docker: upgrade nginx (1.15.11 -> 1.15.12)

## [0.9.4] - 2019-04-13

### Changed

- Docker: upgrade nginx (1.15.9 -> 1.15.11)

## [0.9.3] - 2019-02-28

### Changed

- Docker: upgrade nginx (1.15.6 -> 1.15.9)

## [0.9.2] - 2018-11-13

### Fixed

- Lib: remove second instance of ssl directive

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
