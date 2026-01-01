#!/usr/bin/env bash
# Example hook: Create additional backups before installation
# Place in: /etc/harmonize/hooks.d/pre-install/

log "Creating additional backups before installation..."

CUSTOM_BACKUP_DIR="/root/harmonize-pre-install-backup-$(date +%Y%m%d-%H%M%S)"

if [[ "$DRY_RUN" == "0" ]]; then
  mkdir -p "$CUSTOM_BACKUP_DIR"

  # Backup important files that might be modified
  for file in /etc/bash.bashrc /etc/zsh/zshrc /etc/profile ~/.bashrc ~/.zshrc; do
    if [[ -f "$file" ]]; then
      cp -a "$file" "$CUSTOM_BACKUP_DIR/" 2>/dev/null || true
      log "Backed up: $file"
    fi
  done

  # Create manifest
  cat > "$CUSTOM_BACKUP_DIR/manifest.txt" <<EOF
Harmonize Pre-Installation Backup
Created: $(date -Is)
Hostname: $(hostname)
User: $(whoami)

Files backed up:
$(ls -la "$CUSTOM_BACKUP_DIR" | tail -n +4)
EOF

  log "Custom backup created at: $CUSTOM_BACKUP_DIR"
fi

print_success "Additional backups created"
