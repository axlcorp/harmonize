#!/usr/bin/env bash
# Example hook: Configure Git defaults
# Place in: /etc/harmonize/hooks.d/post-install/

log "Configuring Git defaults..."

if command -v git &>/dev/null; then
  # Set global git config (only if not already set)
  if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
    print_info "Git user.name not set - skipping (set manually)"
  fi
  
  # Useful defaults
  run_cmd git config --global init.defaultBranch main
  run_cmd git config --global core.autocrlf input
  run_cmd git config --global pull.rebase false
  run_cmd git config --global color.ui auto
  
  print_success "Git defaults configured"
else
  print_warning "Git not installed - skipping Git configuration"
fi
