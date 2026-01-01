# Changelog

All notable changes to Harmonize will be documented in this file.

## [2.1.1] - 2026-01-01

### Added

#### 1. Enhanced Test Suite
- **Improved test runner** (`tests/run-tests.sh`)
  - Color-coded output for better readability
  - Support for multiple test modes (basic, modern, all)
  - Verbose mode with `VERBOSE=1`
  - Better error reporting with last 20 lines of failed builds
  - Skipped tests tracking
- **New unit tests** (`tests/unit-tests.sh`)
  - File existence checks
  - Security validation (limited eval usage)
  - Error handling verification (set -e)
  - Managed block marker validation
  - i18n support verification
  - 12 comprehensive tests covering code quality

#### 2. Extended Hook Examples
- **Pre-install hooks**
  - `01-backup-existing.sh` - Additional backup with manifest
- **Post-deps hooks**
  - `01-security-updates.sh` - Automatic security updates (apt/dnf)
- **Post-banners hooks**
  - `01-custom-motd.sh` - Custom welcome message
- **Post-tools hooks**
  - `02-docker-aliases.sh` - Useful Docker command shortcuts
- **Post-install hooks**
  - `03-vim-config.sh` - Modern vim configuration

#### 3. Enhanced Configuration System
- **Improved external config loading**
  - Better error messages when config files fail to load
  - Timeout protection (10s max per file)
  - Validation of downloaded scripts (shebang check)
  - Support for custom banner generator via `CUSTOM_BANNER_GENERATOR`
  - Count and report successfully loaded config files
- **New `download_remote_hooks()` function**
  - Support for `HOOKS_URL` environment variable
  - Future support for remote hook manifests
- **Configuration documentation**
  - New `config/README.md` with comprehensive guide
  - Examples for company-wide standardization
  - Security considerations
  - Environment variables reference

#### 4. Robust Error Handling
- **Enhanced `install_packages()`**
  - Input validation (empty package list check)
  - Detailed error messages with package names
  - Logging of installation output
  - Return code validation
- **Enhanced `backup_file()`**
  - Input validation for source and destination
  - Directory creation error checking
  - Copy operation validation
  - Clear error messages
- **Enhanced `write_file_atomic()`**
  - Destination path validation
  - Temporary file creation error checking
  - Write operation validation
  - Cleanup on failure
  - Atomic move validation
- **Enhanced `install_tool()`**
  - Input parameter validation
  - Installation command error checking
  - Binary verification after installation
  - Version reporting
  - Detailed error messages
- **New `check_prerequisites()` function**
  - Required command validation (curl, perl, mktemp, tee)
  - Disk space check (100MB minimum in /var)
  - Internet connectivity check
  - Helpful error messages
- **Improved `need_root()` error message**
  - Usage examples included
  - Clearer formatting

#### 5. Documentation
- **New TROUBLESHOOTING.md**
  - Installation errors
  - Permission errors
  - Network errors
  - Package manager errors
  - Hook errors
  - Rollback and recovery
  - Debug mode instructions
  - Common questions and answers
- **Updated README.md**
  - Error handling section
  - Testing section
  - Links to troubleshooting guide

### Changed
- `install_dynamic_banner()` now uses `CUSTOM_BANNER_GENERATOR` variable
- `maybe_load_external_config()` provides better feedback and validation
- All critical functions now have input validation
- Error messages are more descriptive and actionable

### Technical Details

**Files Modified:**
- `harmonize.sh` - Core error handling improvements
- `tests/run-tests.sh` - Enhanced with colors and modes
- `README.md` - Added testing and error handling sections

**Files Added:**
- `tests/unit-tests.sh` - New unit test suite
- `config/README.md` - Configuration guide
- `TROUBLESHOOTING.md` - Comprehensive troubleshooting guide
- `CHANGELOG.md` - This file
- `examples/hooks/pre-install/01-backup-existing.sh`
- `examples/hooks/post-deps/01-security-updates.sh`
- `examples/hooks/post-banners/01-custom-motd.sh`
- `examples/hooks/post-tools/02-docker-aliases.sh`
- `examples/hooks/post-install/03-vim-config.sh`

**Lines of Code:**
- Added: ~800 lines of new code and documentation
- Modified: ~150 lines improved error handling
- Total project: ~2300 lines

---

## [2.1.0] - 2026-01-01

### Added
- Initial release with core functionality
- Starship and PS1 prompt modes
- Dynamic and static banner support
- Modern tools pack (zoxide, eza, bat, fzf)
- Extensible hooks system
- Multi-distro support (Debian, Ubuntu, Fedora, Arch)
- Internationalization (EN/FR)
- Interactive wizard
- Automatic backups and rollback

---

## Upgrade Instructions

### From 2.1.0 to 2.1.1

Simply run:
```bash
curl -fsSL <url>/harmonize.sh | sudo bash -s -- update
```

No breaking changes. All improvements are backward compatible.

### Testing Before Upgrade

Use dry-run mode to see what will happen:
```bash
curl -fsSL <url>/harmonize.sh | sudo bash -s -- install --dry-run
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this project.
