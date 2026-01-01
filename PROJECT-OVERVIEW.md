# Harmonize - Project Overview

A comprehensive guide to understanding the Harmonize project structure and architecture.

## 📋 Table of Contents

- [What is Harmonize?](#what-is-harmonize)
- [Project Structure](#project-structure)
- [Core Components](#core-components)
- [Configuration System](#configuration-system)
- [Testing Strategy](#testing-strategy)
- [Documentation](#documentation)

## What is Harmonize?

Harmonize is a production-ready Bash script that unifies and modernizes shell environments across Linux distributions. It provides:

- **Universal shell configuration** (Bash + Zsh)
- **Modern prompts** via Starship or classic PS1
- **Dynamic system banners** with real-time info
- **Extensible hooks** for customization
- **Multi-distro support** (Debian, Ubuntu, Fedora, RHEL, Arch)
- **Modern tools integration** (zoxide, eza, bat, fzf)

## Project Structure

```
harmonize/
├── harmonize.sh              # Main installation script (~1500 lines)
├── preview-output.sh         # Preview banner output
│
├── config/                   # Configuration files
│   ├── banner.txt            # Static banner template
│   ├── generate-banner.sh    # Dynamic banner generator
│   ├── starship.toml         # Starship prompt config
│   └── README.md             # Config documentation
│
├── tests/                    # Test suite
│   ├── quick-check.sh        # Fast sanity checks (35 tests)
│   ├── unit-tests.sh         # Unit tests (16 tests)
│   ├── run-tests.sh          # Multi-distro test runner
│   ├── Dockerfile.debian     # Debian test container
│   ├── Dockerfile.ubuntu     # Ubuntu test container
│   ├── Dockerfile.fedora     # Fedora test container
│   └── Dockerfile.arch       # Arch Linux test container
│
├── examples/                 # Hook examples
│   └── hooks/
│       ├── pre-install/      # Before installation
│       ├── post-deps/        # After dependencies
│       ├── post-banners/     # After banner setup
│       ├── post-tools/       # After modern tools
│       ├── post-shells/      # After shell config
│       └── post-install/     # After installation
│
├── .github/                  # GitHub configuration
│   ├── workflows/
│   │   └── ci.yml            # CI/CD pipeline
│   ├── ISSUE_TEMPLATE/       # Issue templates
│   ├── setup-repo.sh         # Repository setup helper
│   └── publish-checklist.md  # Publication checklist
│
├── README.md                 # English documentation (604 lines)
├── README.fr.md              # French documentation (604 lines)
├── CONTRIBUTING.md           # Contribution guide
├── LICENSE                   # MIT License
├── CHANGELOG.md              # Version history
├── TROUBLESHOOTING.md        # Troubleshooting guide
├── SECURITY.md               # Security policy
├── PUBLISHING.md             # Publishing guide
└── PROJECT-OVERVIEW.md       # This file
```

## Core Components

### 1. Main Script (`harmonize.sh`)

The heart of Harmonize. Key sections:

#### Global Configuration
- Version and constants
- OS detection
- Package manager selection
- Internationalization (EN/FR)

#### Core Functions

**Installation Functions:**
- `install_packages()` - Cross-distro package installation
- `install_tool()` - Generic tool installer
- `install_starship()` - Starship prompt installer
- `install_modern_tools()` - Modern tools pack

**Configuration Functions:**
- `configure_bash()` - Global Bash configuration
- `configure_zsh()` - Global Zsh configuration
- `install_dynamic_banner()` - Dynamic MOTD setup
- `install_static_banner()` - Static banner setup

**Utility Functions:**
- `backup_file()` - Safe file backup with validation
- `write_file_atomic()` - Atomic file writing
- `write_managed_block()` - Managed config sections
- `remove_managed_block()` - Clean removal

**Safety Functions:**
- `create_backup()` - Full system backup
- `rollback()` - Automatic rollback on failure
- `check_prerequisites()` - System validation

**Hook System:**
- `run_hooks()` - Execute hooks at specific points
- `maybe_load_external_config()` - Load remote configs

### 2. Configuration System

#### Static Configuration
- `config/banner.txt` - Simple text banner
- `config/starship.toml` - Starship theme

#### Dynamic Configuration
- `config/generate-banner.sh` - Real-time system info
- `config/99-harmonize-banner` - MOTD script

#### Remote Configuration
Uses `CONFIG_URL_BASE` environment variable:
```bash
export CONFIG_URL_BASE="https://raw.githubusercontent.com/company/configs/main"
```

Auto-loads:
- `banner.txt`
- `starship.toml`
- `generate-banner.sh`

### 3. Hook System

Extensibility points throughout installation:

```
Installation Flow:
├── pre-install/       ← Before anything starts
├── Dependencies installed
├── post-deps/         ← After dependencies
├── Banners configured
├── post-banners/      ← After banners
├── Modern tools installed (optional)
├── post-tools/        ← After modern tools
├── Starship installed (optional)
├── post-starship/     ← After Starship
├── Shell configs applied
├── post-shells/       ← After shell configs
└── post-install/      ← Installation complete
```

Hooks are bash scripts in `/etc/harmonize/hooks.d/`.

**Hook Features:**
- Access to all Harmonize functions
- Access to Harmonize variables
- Logged output
- Error handling
- Must be executable

### 4. Testing Strategy

#### Three Test Levels

**Level 1: Quick Check** (`quick-check.sh`)
- File existence checks
- Documentation completeness
- Basic syntax validation
- Security checks
- **Runtime**: ~2 seconds
- **Tests**: 35 checks

**Level 2: Unit Tests** (`unit-tests.sh`)
- Code quality validation
- Error handling verification
- Managed block validation
- i18n support
- **Runtime**: ~5 seconds
- **Tests**: 16 tests

**Level 3: Integration Tests** (`run-tests.sh`)
- Full installation on Docker containers
- Multi-distro validation
- Modes: basic, modern, all
- **Runtime**: ~5-15 minutes per distro
- **Distributions**: Debian, Ubuntu, Fedora, Arch

#### CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/ci.yml`):

```yaml
Jobs:
  1. Quick Check      - Fast validation
  2. ShellCheck       - Static analysis
  3. Test Debian      - Debian container
  4. Test Ubuntu      - Ubuntu container
  5. Test Fedora      - Fedora container
  6. Test Arch        - Arch container
  7. Documentation    - Doc validation
```

All jobs run in parallel except Debian/Ubuntu/Fedora/Arch which depend on Quick Check.

## Configuration System

### Environment Variables

**Prompt Configuration:**
- `PROMPT_MODE` - `starship` or `ps1`
- `FORCE_STARSHIP_CONFIG` - Update Starship config
- `UPDATE_STARSHIP` - Update Starship binary

**Banner Configuration:**
- `USE_DYNAMIC_BANNER` - `0` or `1`
- `BANNER_TEXT` - Custom static banner
- `CONFIGURE_SSH_BANNER` - Configure SSH banner
- `CUSTOM_BANNER_GENERATOR` - Custom banner script URL

**Shell Configuration:**
- `ENABLE_BASH` - `0` or `1`
- `ENABLE_ZSH` - `0` or `1`

**System Configuration:**
- `KEYBOARD_LAYOUT` - Keyboard layout (fr, us, etc.)
- `LANG` - Language (en, fr)
- `INSTALL_MODERN_TOOLS` - Install modern tools

**Remote Configuration:**
- `CONFIG_URL_BASE` - Base URL for configs
- `HOOKS_URL` - Hooks manifest URL (future)

**Development:**
- `DRY_RUN` - `0` or `1`
- `DEBUG` - Enable debug output

### Installation Modes

**Basic Installation:**
```bash
sudo bash harmonize.sh install
```

**Interactive Mode:**
```bash
sudo bash harmonize.sh install --interactive
```

**With Modern Tools:**
```bash
sudo bash harmonize.sh install --modern-tools
```

**Custom Configuration:**
```bash
CONFIG_URL_BASE="https://..." PROMPT_MODE=starship sudo bash harmonize.sh install
```

## Documentation

### User Documentation

- **README.md** - Main English documentation
- **README.fr.md** - French translation
- **TROUBLESHOOTING.md** - Problem solving guide
- **config/README.md** - Configuration guide

### Developer Documentation

- **CONTRIBUTING.md** - How to contribute
- **PROJECT-OVERVIEW.md** - This file
- **CHANGELOG.md** - Version history
- **examples/hooks/README.md** - Hook examples

### GitHub Documentation

- **SECURITY.md** - Security policy
- **PUBLISHING.md** - Publication guide
- **.github/README.md** - GitHub setup
- **.github/publish-checklist.md** - Publication checklist

## Key Design Principles

### 1. Idempotency
Safe to run multiple times without side effects.

### 2. Safety First
- Automatic backups before changes
- Rollback on failure
- Input validation
- Error handling

### 3. Cross-Distribution
Works on Debian, Ubuntu, Fedora, RHEL, Arch without modifications.

### 4. Extensibility
Hook system allows customization without modifying core script.

### 5. User Choice
Respects user preferences via environment variables.

### 6. Minimal Dependencies
Only requires: bash, curl, perl, coreutils.

### 7. Clear Separation
Managed blocks clearly mark Harmonize-controlled sections.

### 8. Observability
Comprehensive logging to `/var/log/prompt-harmonizer.log`.

## Development Workflow

### Making Changes

1. **Clone repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/harmonize.git
   cd harmonize
   ```

2. **Create branch**
   ```bash
   git checkout -b feature/my-feature
   ```

3. **Make changes**
   - Edit `harmonize.sh` or other files
   - Follow bash style guide (see CONTRIBUTING.md)

4. **Test changes**
   ```bash
   # Quick validation
   ./tests/quick-check.sh

   # Unit tests
   ./tests/unit-tests.sh

   # Full Docker test (example)
   docker build -f tests/Dockerfile.debian .
   ```

5. **Commit**
   ```bash
   git add .
   git commit -m "feat: add my feature"
   ```

6. **Push and PR**
   ```bash
   git push origin feature/my-feature
   # Create PR on GitHub
   ```

### Common Development Tasks

**Add a new function:**
1. Add to `harmonize.sh` with proper error handling
2. Add unit test to `tests/unit-tests.sh`
3. Update documentation in README.md

**Add a new hook example:**
1. Create script in `examples/hooks/<phase>/`
2. Make executable: `chmod +x`
3. Document in `examples/hooks/README.md`

**Add distribution support:**
1. Update OS detection in `harmonize.sh`
2. Add package manager support
3. Create Dockerfile in `tests/`
4. Update CI workflow

**Fix a bug:**
1. Reproduce issue
2. Write test that fails
3. Fix bug
4. Verify test passes
5. Update CHANGELOG.md

## Questions?

- Read [CONTRIBUTING.md](CONTRIBUTING.md)
- Read [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- Open a GitHub issue
- Start a discussion

---

**Version**: 2.1.1
**Last Updated**: 2026-01-01
