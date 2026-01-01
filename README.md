# 🎨 Prompt Harmonizer

**Unify and modernize your shell environment across all Linux machines**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/Bash-5.0+-green.svg)](https://www.gnu.org/software/bash/)
[![Tested](https://img.shields.io/badge/Tested-Debian%20%7C%20Ubuntu%20%7C%20Fedora%20%7C%20Arch-success.svg)](tests/)

A powerful, production-ready script to **harmonize shell prompts**, **system banners**, and **development tools** across all your Linux infrastructure (VMs, containers, bare metal, cloud instances).

```bash
# One command to rule them all
curl -fsSL https://raw.githubusercontent.com/<you>/harmonize/main/harmonize.sh | sudo bash -s -- install
```

---

## ✨ Features

### 🚀 Core Features

- **🎯 Universal Compatibility**: Debian, Ubuntu, Fedora, RHEL, Arch Linux
- **🐚 Dual Shell Support**: Bash + Zsh with unified configuration
- **⭐ Starship Prompt**: Modern, fast, and customizable (or fallback to classic PS1)
- **📊 Smart Badges**: Auto-detects ROLE, SSH, Containers, Docker, Kubernetes contexts
- **🎨 Dynamic Banners**: Real-time system information on login (MOTD)
- **🔧 Modern Shell Pack**: Optional installation of zoxide, eza, bat, fzf
- **🪝 Extensible Hooks**: Plugin system for custom installation steps
- **🌍 Internationalization**: English + French (auto-detected)
- **🔄 Idempotent**: Safe to run multiple times
- **⚡ Auto-Rollback**: Automatic recovery on failure
- **📦 Centralized Config**: Load configurations from remote Git repositories

### 🎭 Installation Experience

Beautiful, professional installation with:
- ╔═══╗ Bordered header with version
- [1/6] Step-by-step progress indicators
- ✓ Color-coded status messages
- 📦 Installation summary box
- 💾 Automatic backups with timestamps

---

## 📸 Preview

### Starship Prompt with Context Badges

```
┌─ alex@prod-server [ROLE:pve] [SSH] [DOCKER:default] in ~/projects
└❯
```

### Dynamic MOTD Banner

```
    🖥  OS:          Ubuntu 22.04.3 LTS        ⏱  Uptime:      45 days, 3 hours
    🏠 Host:        prod-web-01                💡 IP:          192.168.1.10
    🏷  Role:        production                 🧠 Load:        0.45 0.52 0.48

    💾 Mem:        [||||||||..] 78%             💽 Disk /:     [|||||.....] 45%
```

---

## 🚀 Quick Start

### Basic Installation

```bash
# Install with defaults (Starship prompt + dynamic banner)
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/harmonize/main/harmonize.sh | sudo bash -s -- install
```

### Interactive Installation

```bash
# Launch configuration wizard
curl -fsSL https://... | sudo bash -s -- install --interactive
```

### With Modern Tools

```bash
# Include zoxide, eza, bat, fzf
curl -fsSL https://... | sudo bash -s -- install --modern-tools
```

### Advanced Options

```bash
# Multiple options
curl -fsSL https://... | sudo bash -s -- install \
  --interactive \
  --modern-tools \
  --keyboard fr \
  --lang fr
```

---

## 📖 Usage

### Commands

```bash
# Install or update
sudo bash harmonize.sh install
sudo bash harmonize.sh update

# Uninstall (keeps Starship by default)
sudo bash harmonize.sh uninstall

# Uninstall including Starship
REMOVE_STARSHIP=1 sudo bash harmonize.sh uninstall

# Dry-run (preview changes without applying)
sudo bash harmonize.sh install --dry-run
```

### Environment Variables

#### Prompt Configuration

```bash
# Choose prompt mode
PROMPT_MODE=starship sudo bash harmonize.sh install  # Default
PROMPT_MODE=ps1 sudo bash harmonize.sh install       # Simple prompt

# Force update Starship config
FORCE_STARSHIP_CONFIG=1 sudo bash harmonize.sh update

# Update Starship binary during update
UPDATE_STARSHIP=1 sudo bash harmonize.sh update
```

#### Banner Configuration

```bash
# Use dynamic banner (default)
USE_DYNAMIC_BANNER=1 sudo bash harmonize.sh install

# Use static banner
USE_DYNAMIC_BANNER=0 BANNER_TEXT="Welcome\n" sudo bash harmonize.sh install

# Configure SSH banner
CONFIGURE_SSH_BANNER=1 sudo bash harmonize.sh install  # Default
CONFIGURE_SSH_BANNER=0 sudo bash harmonize.sh install  # Skip
```

#### Shell Configuration

```bash
# Configure both shells (default)
ENABLE_BASH=1 ENABLE_ZSH=1 sudo bash harmonize.sh install

# Bash only
ENABLE_BASH=1 ENABLE_ZSH=0 sudo bash harmonize.sh install

# Zsh only
ENABLE_BASH=0 ENABLE_ZSH=1 sudo bash harmonize.sh install
```

#### System Configuration

```bash
# Set keyboard layout
sudo bash harmonize.sh install --keyboard fr

# Set language
sudo bash harmonize.sh install --lang fr

# Install modern tools
INSTALL_MODERN_TOOLS=1 sudo bash harmonize.sh install
```

---

## 🎯 Context Badges

Harmonize automatically detects your environment and displays relevant badges:

### ROLE Badge

Create `/etc/role` with your server's role:

```bash
# Examples
echo "prod" | sudo tee /etc/role        # Production server
echo "dev" | sudo tee /etc/role         # Development
echo "pve" | sudo tee /etc/role         # Proxmox VE
echo "k8s-worker" | sudo tee /etc/role  # Kubernetes worker
echo "docker" | sudo tee /etc/role      # Docker host
```

If `/etc/role` doesn't exist, Harmonize uses heuristics:
- Detects Proxmox VE → `pve`
- Detects Docker → `docker`
- Detects Kubernetes → `k8s`

### Auto-Detected Badges

- **SSH**: Shown when connected via SSH (`$SSH_CONNECTION`)
- **CT**: Container detection (Docker, LXC via `/.dockerenv`, `/run/.containerenv`, cgroups)
- **DOCKER:context**: Current Docker context if docker is available
- **K8S:context**: Current kubectl context if kubectl is available

---

## 🪝 Hooks System

Extend Harmonize with custom scripts at specific execution points.

### Available Hooks

| Hook Point | When It Runs | Use Case |
|------------|--------------|----------|
| `pre-install/` | Before installation starts | Custom backups, validations |
| `post-deps/` | After dependencies installed | Configure repos, security |
| `post-banners/` | After banners configured | Custom MOTD messages |
| `post-tools/` | After modern tools installed | Tool-specific configs |
| `post-starship/` | After Starship installed | Custom Starship modules |
| `post-shells/` | After shell configs applied | Shell aliases, functions |
| `post-install/` | After installation complete | Additional software, final setup |
| `pre-uninstall/` | Before uninstallation | Cleanup preparation |
| `post-uninstall/` | After uninstallation | Final cleanup |

### Creating Hooks

**1. Create the hook script:**

```bash
sudo nano /etc/harmonize/hooks.d/post-install/01-my-tools.sh
```

**2. Write your hook:**

```bash
#!/usr/bin/env bash
# Install company-standard tools

log "Installing company tools..."

# Use Harmonize functions
install_packages htop ncdu tree jq

# Access Harmonize variables
if [[ "$OS_ID" == "ubuntu" ]]; then
  install_packages ubuntu-specific-tool
fi

print_success "Company tools installed"
```

**3. Make it executable:**

```bash
sudo chmod +x /etc/harmonize/hooks.d/post-install/01-my-tools.sh
```

### Hook Examples

Check [`examples/hooks/`](examples/hooks/) for ready-to-use examples:

- **Security Updates**: Automatic security patching
- **Docker Aliases**: Useful Docker shortcuts
- **Vim Configuration**: Modern vim setup
- **Tmux Configuration**: Sane tmux defaults
- **Custom MOTD**: Welcome messages
- **Pre-install Backup**: Additional safety backups

### Available Functions in Hooks

Hooks have access to all Harmonize functions:

```bash
# Package management
install_packages pkg1 pkg2 pkg3

# Logging
log "message"
print_success "Success message"
print_info "Info message"
print_warning "Warning message"
print_error "Error message"

# Variables
$OS_ID           # debian, ubuntu, fedora, arch, etc.
$PKG_MGR         # apt, dnf, pacman
$DRY_RUN         # 0 or 1
$PROMPT_MODE     # starship or ps1
```

---

## 🌐 Centralized Configuration

Load configurations from a remote Git repository for consistent deployments.

### Setup

**1. Create a configuration repository:**

```bash
git init harmonize-config
cd harmonize-config

# Add custom banner
cat > banner.txt <<'EOF'
╔═══════════════════════════════════════╗
║   ACME Corp - Authorized Access Only  ║
╚═══════════════════════════════════════╝
EOF

# Add custom Starship config
cp ~/.config/starship.toml .

# Add custom banner generator (optional)
cp /path/to/generate-banner.sh .

git add .
git commit -m "Initial config"
git push origin main
```

**2. Use the configuration:**

```bash
export CONFIG_URL_BASE="https://raw.githubusercontent.com/acme-corp/harmonize-config/main"
curl -fsSL https://... | sudo -E bash -s -- install
```

### Configuration Files

| File | Purpose | Auto-Loaded |
|------|---------|-------------|
| `banner.txt` | Static banner text | ✅ Yes |
| `starship.toml` | Starship configuration | ✅ Yes |
| `generate-banner.sh` | Dynamic banner generator | ✅ Yes |

See [config/README.md](config/README.md) for detailed documentation.

---

## 📁 File Locations

### Installation Files

```
/usr/local/bin/starship              # Starship binary
/usr/local/bin/harmonize-banner      # Dynamic banner generator
/etc/bash.bashrc                     # Global Bash config
/etc/zsh/zshrc                       # Global Zsh config
/etc/issue                           # Console login banner
/etc/issue.net                       # Network login banner
/etc/ssh/sshd_config                 # SSH daemon config (if enabled)
/etc/update-motd.d/99-harmonize-banner  # MOTD script
```

### State & Logs

```
/var/lib/prompt-harmonizer/
  └── state.env                      # Installation state

/var/log/prompt-harmonizer.log       # Detailed logs

/var/backups/prompt-harmonizer/
  └── backup-YYYYMMDD-HHMMSS/        # Automatic backups
```

### Hooks

```
/etc/harmonize/hooks.d/
  ├── pre-install/
  ├── post-deps/
  ├── post-banners/
  ├── post-tools/
  ├── post-starship/
  ├── post-shells/
  ├── post-install/
  ├── pre-uninstall/
  └── post-uninstall/
```

### User Configuration

```
~/.config/starship.toml              # Per-user Starship config
                                     # (root + all UID >= 1000)
```

---

## 🧪 Testing

Harmonize includes a comprehensive test suite:

### Quick Sanity Check

```bash
./tests/quick-check.sh
# Runs 35+ checks in seconds
```

### Unit Tests

```bash
./tests/unit-tests.sh
# 16 automated tests
```

### Full Test Suite

```bash
# Test on all supported distributions
./tests/run-tests.sh

# Verbose output
VERBOSE=1 ./tests/run-tests.sh

# Test specific mode
TEST_MODE=basic ./tests/run-tests.sh
```

### Docker Testing

```bash
# Test on Debian
docker build -t harmonize-test -f tests/Dockerfile.debian .

# Test on Ubuntu with modern tools
docker build -t harmonize-test -f tests/Dockerfile.ubuntu .

# Test on Fedora
docker build -t harmonize-test -f tests/Dockerfile.fedora .

# Test on Arch Linux
docker build -t harmonize-test -f tests/Dockerfile.arch .
```

---

## 🔒 Security & Safety

### Built-in Safety Features

- ✅ **Automatic backups** before any modifications
- ✅ **Rollback on failure** - automatic recovery if installation fails
- ✅ **Idempotent operations** - safe to run multiple times
- ✅ **Managed blocks** - clear markers for Harmonize-controlled sections
- ✅ **Input validation** - all functions validate parameters
- ✅ **Error handling** - comprehensive error checking and reporting
- ✅ **Prerequisite checks** - verifies system requirements before installation
- ✅ **Dry-run mode** - preview changes without applying them

### Security Best Practices

1. **Review before installing**: Use `--dry-run` to preview changes
2. **Verify downloads**: Always use HTTPS URLs
3. **Check hooks**: Review hook scripts before execution (they run as root)
4. **Use version control**: Pin to specific versions for production
5. **Test first**: Use Docker containers for testing

### Rollback

Automatic rollback on failure, or manual restoration:

```bash
# View backups
ls -la /var/backups/prompt-harmonizer/

# Manual restore (if needed)
BACKUP_DIR=/var/backups/prompt-harmonizer/backup-YYYYMMDD-HHMMSS
sudo cp -a $BACKUP_DIR/bash.bashrc /etc/
sudo cp -a $BACKUP_DIR/issue /etc/
```

---

## 🐛 Troubleshooting

### Common Issues

**"This script must be run as root"**
```bash
# Solution: Use sudo
sudo bash harmonize.sh install
```

**"Missing required commands"**
```bash
# Debian/Ubuntu
sudo apt-get install curl perl coreutils

# Fedora/RHEL
sudo dnf install curl perl coreutils
```

**"Starship not in PATH"**
```bash
# Add to PATH
export PATH=$PATH:/usr/local/bin
source /etc/bash.bashrc
```

**Installation failed**
```bash
# Check logs
tail -100 /var/log/prompt-harmonizer.log

# Automatic rollback will restore previous state
```

See **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** for comprehensive troubleshooting guide.

---

## 📚 Documentation

- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Detailed troubleshooting guide
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute
- **[config/README.md](config/README.md)** - Centralized configuration guide
- **[LICENSE](LICENSE)** - MIT License

---

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development

```bash
# Clone repository
git clone https://github.com/axlcorp@gmail.com/harmonize.git
cd harmonize

# Run tests
./tests/quick-check.sh
./tests/unit-tests.sh

# Test changes
sudo bash harmonize.sh install --dry-run
```

---

## 📜 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🙏 Credits

- **[Starship](https://starship.rs/)** - The minimal, blazing-fast, and infinitely customizable prompt
- **Modern Shell Tools**: [zoxide](https://github.com/ajeetdsouza/zoxide), [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [fzf](https://github.com/junegunn/fzf)

---

## 🎯 Use Cases

### Infrastructure Standardization

Deploy consistent shell environments across:
- 🏢 **Corporate infrastructure** - Unified experience for all admins
- ☁️ **Cloud deployments** - AWS, Azure, GCP instances
- 🐳 **Container environments** - Docker, Kubernetes nodes
- 💻 **Homelab** - Proxmox VE, LXC containers, VMs
- 🔬 **Development environments** - Local machines, dev servers

### Team Collaboration

- Share configurations via Git repositories
- Enforce company standards with hooks
- Provide context awareness (prod/dev/staging roles)
- Simplify onboarding for new team members

---

## 📊 Quick Comparison

| Feature | Harmonize | Manual Setup | Other Tools |
|---------|-----------|--------------|-------------|
| Multi-distro support | ✅ 5 distros | ⚠️ Manual per distro | ⚠️ Limited |
| Automatic rollback | ✅ Yes | ❌ No | ⚠️ Rare |
| Hooks system | ✅ 9 points | ❌ No | ⚠️ Limited |
| Centralized config | ✅ Git-based | ❌ Manual sync | ⚠️ Varies |
| Dynamic banners | ✅ Built-in | ⚠️ Custom scripts | ❌ No |
| Idempotent | ✅ Yes | ⚠️ Depends | ⚠️ Varies |
| Test suite | ✅ 35+ tests | ❌ No | ⚠️ Limited |

---

<div align="center">

**Made with ❤️ for system administrators and DevOps engineers**

[Report Bug](https://github.com/axlcorp@gmail.com/harmonize/issues) · [Request Feature](https://github.com/axlcorp@gmail.com/harmonize/issues) · [Documentation](https://github.com/axlcorp@gmail.com/harmonize/wiki)

</div>
