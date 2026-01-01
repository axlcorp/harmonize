# Troubleshooting Guide

This guide helps you diagnose and fix common issues with Harmonize.

## Table of Contents

- [Installation Errors](#installation-errors)
- [Permission Errors](#permission-errors)
- [Network Errors](#network-errors)
- [Package Manager Errors](#package-manager-errors)
- [Hook Errors](#hook-errors)
- [Rollback and Recovery](#rollback-and-recovery)

---

## Installation Errors

### Error: "This script must be run as root or with sudo"

**Cause:** The script requires root privileges to modify system files and install packages.

**Solution:**
```bash
sudo bash harmonize.sh install
# OR
curl -fsSL <url>/harmonize.sh | sudo bash -s -- install
```

### Error: "Missing required commands: curl perl mktemp tee"

**Cause:** Required system utilities are not installed.

**Solution:**

**Debian/Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install curl perl coreutils
```

**Fedora/RHEL:**
```bash
sudo dnf install curl perl coreutils
```

**Arch:**
```bash
sudo pacman -S curl perl coreutils
```

### Error: "No supported package manager found"

**Cause:** Your distribution is not supported or package manager is not detected.

**Solution:**
- Check if you're on a supported distribution (Debian, Ubuntu, Fedora, RHEL, Arch)
- Manually install `apt-get`, `dnf`, or `pacman` depending on your distro
- Open an issue on GitHub with your OS details: `cat /etc/os-release`

---

## Permission Errors

### Error: "Failed to create backup directory"

**Cause:** Insufficient permissions or disk space.

**Solution:**
```bash
# Check disk space
df -h /var

# Check permissions
ls -ld /var/backups

# Create directory manually
sudo mkdir -p /var/backups/prompt-harmonizer
sudo chmod 755 /var/backups/prompt-harmonizer
```

### Error: "Failed to write to /etc/bash.bashrc"

**Cause:** File is read-only or immutable.

**Solution:**
```bash
# Check file attributes
lsattr /etc/bash.bashrc

# Remove immutable flag if present
sudo chattr -i /etc/bash.bashrc

# Retry installation
sudo bash harmonize.sh install
```

---

## Network Errors

### Error: "Internet connectivity check failed"

**Cause:** No internet access or firewall blocking connections.

**Solution:**
```bash
# Test connectivity
curl -I https://starship.rs

# If behind a proxy, set proxy environment variables
export http_proxy="http://proxy.example.com:8080"
export https_proxy="http://proxy.example.com:8080"

# Retry installation
sudo -E bash harmonize.sh install
```

### Error: "Could not load banner.txt from CONFIG_URL_BASE"

**Cause:** Config URL is unreachable or files don't exist.

**Solution:**
```bash
# Test URL manually
curl -fsSL "$CONFIG_URL_BASE/banner.txt"

# Check if URL is correct
echo $CONFIG_URL_BASE

# Use local config instead
unset CONFIG_URL_BASE
sudo bash harmonize.sh install
```

---

## Package Manager Errors

### Error: "Failed to update package lists" (apt)

**Cause:** Repository issues or network problems.

**Solution:**
```bash
# Try manual update
sudo apt-get update

# Check repository configuration
ls /etc/apt/sources.list.d/

# Fix broken packages
sudo apt-get update --fix-missing
sudo dpkg --configure -a

# Retry installation
sudo bash harmonize.sh install
```

### Error: "Failed to install packages" (dnf)

**Cause:** Package not found or conflicts.

**Solution:**
```bash
# Check package availability
dnf search <package-name>

# Clear cache
sudo dnf clean all

# Retry
sudo bash harmonize.sh install
```

---

## Hook Errors

### Error: "Hook failed: post-install/01-custom.sh"

**Cause:** Hook script has errors or missing dependencies.

**Solution:**
```bash
# Check hook script
cat /etc/harmonize/hooks.d/post-install/01-custom.sh

# Run hook manually to see error
sudo bash /etc/harmonize/hooks.d/post-install/01-custom.sh

# Fix errors in the hook
sudo nano /etc/harmonize/hooks.d/post-install/01-custom.sh

# Retry installation
sudo bash harmonize.sh install
```

### Error: "Skipping non-executable hook"

**Cause:** Hook script is not executable.

**Solution:**
```bash
# Make hook executable
sudo chmod +x /etc/harmonize/hooks.d/post-install/01-custom.sh

# Retry installation
sudo bash harmonize.sh install
```

---

## Rollback and Recovery

### Automatic Rollback

If installation fails, Harmonize automatically rolls back changes:

```bash
# Check logs
tail -100 /var/log/prompt-harmonizer.log

# Backups are stored in
ls -la /var/backups/prompt-harmonizer/
```

### Manual Rollback

If you need to manually restore files:

```bash
# Find latest backup
LATEST_BACKUP=$(ls -t /var/backups/prompt-harmonizer/ | head -n1)

# Restore files
sudo cp -a /var/backups/prompt-harmonizer/$LATEST_BACKUP/bash.bashrc /etc/
sudo cp -a /var/backups/prompt-harmonizer/$LATEST_BACKUP/issue /etc/
sudo cp -a /var/backups/prompt-harmonizer/$LATEST_BACKUP/issue.net /etc/
```

### Full Uninstall

To completely remove Harmonize:

```bash
# Uninstall (keeps Starship)
sudo bash harmonize.sh uninstall

# Uninstall and remove Starship
REMOVE_STARSHIP=1 sudo bash harmonize.sh uninstall

# Remove all state and backups
sudo rm -rf /var/lib/prompt-harmonizer
sudo rm -rf /var/backups/prompt-harmonizer
sudo rm -rf /etc/harmonize
sudo rm -f /var/log/prompt-harmonizer.log
```

---

## Starship-Specific Issues

### Error: "Starship install failed"

**Cause:** Download failed or installation script error.

**Solution:**
```bash
# Install Starship manually
curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b /usr/local/bin

# Verify installation
starship --version

# Retry Harmonize
sudo bash harmonize.sh install
```

### Starship prompt not showing

**Cause:** Shell config not loaded or Starship not in PATH.

**Solution:**
```bash
# Check if Starship is installed
which starship

# Add to PATH if needed
export PATH=$PATH:/usr/local/bin

# Reload shell config
source /etc/bash.bashrc  # or /etc/zsh/zshrc

# Or open a new shell
```

---

## Debug Mode

Run Harmonize with debug output:

```bash
# Dry-run mode (no changes)
sudo bash harmonize.sh install --dry-run

# Verbose logging
set -x
sudo bash harmonize.sh install 2>&1 | tee harmonize-debug.log
set +x

# Check detailed logs
cat /var/log/prompt-harmonizer.log
```

---

## Getting Help

If you're still having issues:

1. **Check the logs:**
   ```bash
   tail -100 /var/log/prompt-harmonizer.log
   ```

2. **Gather system information:**
   ```bash
   cat /etc/os-release
   uname -a
   df -h
   ```

3. **Report the issue:**
   - Create an issue on GitHub
   - Include OS version, error message, and relevant logs
   - Use `--dry-run` to show what would happen

---

## Common Questions

### Q: Can I customize the banner?

**A:** Yes, either:
- Set `BANNER_TEXT` environment variable
- Use `CONFIG_URL_BASE` to load from remote
- Edit `/etc/issue` and `/etc/issue.net` directly after installation

### Q: How do I update Starship?

**A:**
```bash
UPDATE_STARSHIP=1 sudo bash harmonize.sh update
```

### Q: Can I skip certain configuration steps?

**A:** Yes, use environment variables:
```bash
ENABLE_BASH=0 sudo bash harmonize.sh install  # Skip Bash config
ENABLE_ZSH=0 sudo bash harmonize.sh install   # Skip Zsh config
CONFIGURE_SSH_BANNER=0 sudo bash harmonize.sh install  # Skip SSH banner
```

### Q: Is it safe to run multiple times?

**A:** Yes, Harmonize is idempotent. Running `install` or `update` multiple times is safe.
