# Harmonize Configuration Files

This directory contains optional configuration files that can be served from a central repository and loaded by Harmonize installations.

## Usage

Set the `CONFIG_URL_BASE` environment variable to point to your config repository:

```bash
export CONFIG_URL_BASE="https://raw.githubusercontent.com/yourusername/harmonize-config/main"
bash harmonize.sh install
```

## Available Configuration Files

### `banner.txt`
Static banner text for `/etc/issue` and `/etc/issue.net`.

**Example:**
```
┌─────────────────────────────────────────┐
│  Production Server - Authorized Only    │
│  All access is logged and monitored     │
└─────────────────────────────────────────┘
```

### `generate-banner.sh`
Dynamic banner generator script for MOTD.

This script is executed on every login to generate a fresh banner with system information.

**Requirements:**
- Must be executable bash script
- Should output to stdout
- Has access to system commands (uptime, df, free, etc.)

### `starship.toml`
Starship prompt configuration.

This file is deployed to `~/.config/starship.toml` for all users (root + UID >= 1000).

**Customization:**
- Badge colors and symbols
- Command timeout
- Directory truncation
- Git status format
- Custom modules

### `hooks/`
Custom hooks directory structure.

You can maintain a complete hooks directory in your config repository:

```
config/
└── hooks/
    ├── pre-install/
    ├── post-deps/
    ├── post-banners/
    ├── post-tools/
    ├── post-starship/
    ├── post-shells/
    └── post-install/
```

**Usage:**
```bash
export CONFIG_URL_BASE="https://raw.githubusercontent.com/yourusername/harmonize-config/main"
export HOOKS_URL="${CONFIG_URL_BASE}/hooks"
bash harmonize.sh install
```

## Configuration Repository Structure

Recommended structure for your configuration repository:

```
your-config-repo/
├── README.md
├── banner.txt
├── generate-banner.sh
├── starship.toml
├── 99-harmonize-banner          # Optional MOTD script
└── hooks/
    ├── pre-install/
    │   └── 01-custom-backup.sh
    ├── post-deps/
    │   └── 01-security-updates.sh
    ├── post-install/
    │   ├── 01-productivity-tools.sh
    │   ├── 02-git-defaults.sh
    │   └── 03-vim-config.sh
    └── post-tools/
        └── 01-docker-aliases.sh
```

## Example: Company-Wide Standardization

Create a company config repository:

**1. Create repository:**
```bash
git init harmonize-company-config
cd harmonize-company-config
```

**2. Add banner:**
```bash
cat > banner.txt <<'EOF'
╔═══════════════════════════════════════════════╗
║                                               ║
║          ACME Corp Infrastructure             ║
║                                               ║
║  Authorized Personnel Only                    ║
║  All activity is monitored and logged         ║
║                                               ║
╚═══════════════════════════════════════════════╝
EOF
```

**3. Add custom Starship config:**
```bash
cp /path/to/custom/starship.toml .
```

**4. Add company hooks:**
```bash
mkdir -p hooks/post-install
cat > hooks/post-install/01-company-tools.sh <<'EOF'
#!/usr/bin/env bash
log "Installing ACME Corp standard tools..."
install_packages htop ncdu tree jq curl wget git vim
print_success "Company tools installed"
EOF
chmod +x hooks/post-install/01-company-tools.sh
```

**5. Push to GitHub:**
```bash
git add .
git commit -m "Initial company Harmonize config"
git push origin main
```

**6. Deploy to servers:**
```bash
export CONFIG_URL_BASE="https://raw.githubusercontent.com/acme-corp/harmonize-config/main"
curl -fsSL https://raw.githubusercontent.com/yourusername/harmonize/main/harmonize.sh | \
  sudo -E bash -s -- install
```

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `CONFIG_URL_BASE` | Base URL for config files | `https://raw.githubusercontent.com/user/repo/main` |
| `BANNER_TEXT` | Override banner text directly | `"Welcome to Server\n"` |
| `STARSHIP_TOML` | Override Starship config directly | `$(cat custom.toml)` |
| `HOOKS_DIR` | Custom hooks directory path | `/opt/company/harmonize-hooks` |

## Security Considerations

1. **Trust your sources**: Only use `CONFIG_URL_BASE` from repositories you control
2. **HTTPS required**: Always use HTTPS URLs, never HTTP
3. **Review hooks**: Hooks run with root privileges - always review before deploying
4. **Version control**: Keep configs in git for audit trail
5. **Access control**: Use private repositories for sensitive configurations

## Tips

- Use separate branches for different environments (dev, staging, prod)
- Tag releases for versioned deployments
- Include a `VERSION` file to track config version
- Document any custom variables or requirements
- Test configs in Docker containers before deploying
