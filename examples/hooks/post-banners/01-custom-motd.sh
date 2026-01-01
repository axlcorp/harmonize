#!/usr/bin/env bash
# Example hook: Add custom MOTD message
# Place in: /etc/harmonize/hooks.d/post-banners/

log "Adding custom MOTD message..."

if [[ "$DRY_RUN" == "0" ]]; then
  # Create a custom MOTD script
  cat > /etc/update-motd.d/10-harmonize-welcome <<'WELCOMESCRIPT'
#!/bin/bash
# Custom welcome message

C_BOLD='\033[1m'
C_BLUE='\033[0;34m'
C_RESET='\033[0m'

echo ""
echo -e "${C_BOLD}${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo -e "${C_BOLD}  Welcome to $(hostname)${C_RESET}"
echo -e "${C_BOLD}${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo ""

# Show useful commands
cat <<'EOF'
  Useful commands:
    • System status:  systemctl status
    • Disk usage:     df -h
    • Memory usage:   free -h
    • Running tasks:  htop
    • Logs:           journalctl -xe

EOF
WELCOMESCRIPT

  chmod +x /etc/update-motd.d/10-harmonize-welcome
  log "Created custom MOTD welcome message"
fi

print_success "Custom MOTD message added"
