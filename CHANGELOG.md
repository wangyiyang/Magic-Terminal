# Changelog

All notable changes to Magic Terminal will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- GitHub Actions CI/CD workflow for automated builds and releases
- Cross-platform binary building (Linux, macOS, Windows)
- GUI application packaging for all platforms
- Release automation scripts
- macOS DMG installer creation and packaging
- Comprehensive build system with Makefile
- Code quality checks with golangci-lint
- Test coverage reporting
- Security scanning with gosec
- AUTHORS file with contributor information
- Updated LICENSE with dual copyright (Magic Terminal + original fyne-io/terminal)
- Code quality checks with golangci-lint
- Test coverage reporting
- Security scanning with gosec

### Changed

- Project forked from fyne-io/terminal to Magic Terminal
- Updated all import paths to github.com/wangyiyang/Magic-Terminal
- Modernized build system with comprehensive Makefile
- Updated README with Chinese and English versions

### Fixed

- Build system compatibility across platforms
- Fyne packaging with latest tools

## [0.1.0] - TBD

### Added

- Initial release of Magic Terminal
- Terminal emulator functionality based on Fyne toolkit
- Support for Linux, macOS, Windows, and BSD
- Modern UI with customizable themes
- Mouse and keyboard input handling
- Color support (ANSI, xterm 256-color, 24-bit)
- Scrollback buffer
- Text selection and clipboard operations
- Printing support

### Technical

- Go 1.23.0+ support
- Fyne v2.6.1+ integration
- Cross-platform PTY support
- Comprehensive test suite
- GitHub Actions CI/CD pipeline
- Automated release process

---

## Release Process

1. Update CHANGELOG.md with new version information
2. Run `make pre-release` to ensure everything is ready
3. Create and push release tag: `make quick-release VERSION=v1.0.0`
4. GitHub Actions will automatically build and publish release artifacts

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality additions  
- **PATCH** version for backwards-compatible bug fixes
