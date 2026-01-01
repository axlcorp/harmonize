# Example Hooks for Harmonize

This directory contains example hooks that you can use as templates.

## Installation

Copy the desired hook to the appropriate directory in `/etc/harmonize/hooks.d/`:

```bash
# Example: Install the productivity tools hook
sudo cp post-install/01-productivity-tools.sh /etc/harmonize/hooks.d/post-install/
sudo chmod +x /etc/harmonize/hooks.d/post-install/01-productivity-tools.sh
```

## Available Examples

### post-install/

| Hook | Description |
|------|-------------|
| `01-productivity-tools.sh` | Installs htop, ncdu, tree, jq |
| `02-git-defaults.sh` | Configures sensible Git defaults |

### post-tools/

| Hook | Description |
|------|-------------|
| `01-neovim.sh` | Installs Neovim and sets as default editor |

### post-shells/

| Hook | Description |
|------|-------------|
| `01-tmux.sh` | Installs tmux with a sensible default config |

## Writing Your Own Hooks

Hooks are sourced (not executed), so you have access to all Harmonize functions:

```bash
#!/usr/bin/env bash

# Available functions:
install_packages pkg1 pkg2...   # Install packages (auto-detects distro)
log "message"                   # Log to /var/log/prompt-harmonizer.log
print_success "message"         # Green checkmark
print_info "message"            # Blue info icon
print_warning "message"         # Yellow warning
print_error "message"           # Red X
run_cmd command args...         # Run command (respects --dry-run)

# Available variables:
$OS_ID      # debian, ubuntu, fedora, arch, etc.
$PKG_MGR    # apt, dnf, pacman
$DRY_RUN    # 1 if --dry-run was passed
$HOOKS_DIR  # /etc/harmonize/hooks.d
```

## Hook Naming Convention

- Prefix with numbers for ordering: `01-first.sh`, `02-second.sh`
- Use descriptive names: `post-install/setup-docker.sh`
- Always make hooks executable: `chmod +x hook.sh`
