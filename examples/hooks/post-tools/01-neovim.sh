#!/usr/bin/env bash
# Example hook: Install and configure Neovim
# Place in: /etc/harmonize/hooks.d/post-tools/

log "Installing Neovim..."

# Install neovim
case "$OS_ID" in
  debian|ubuntu)
    install_packages neovim
    ;;
  fedora|rhel|centos)
    install_packages neovim
    ;;
  arch)
    install_packages neovim
    ;;
esac

# Set as default editor for all users
if command -v nvim &>/dev/null; then
  # Create alternatives symlink (Debian/Ubuntu)
  if command -v update-alternatives &>/dev/null; then
    run_cmd update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 100
  fi
  
  # Add EDITOR to /etc/environment
  if ! grep -q "EDITOR=" /etc/environment 2>/dev/null; then
    echo 'EDITOR=nvim' >> /etc/environment
  fi
  
  print_success "Neovim installed and set as default editor"
else
  print_warning "Neovim installation failed"
fi
