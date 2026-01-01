#!/usr/bin/env bash
# Example hook: Install additional productivity tools
# Place in: /etc/harmonize/hooks.d/post-install/

# This hook runs after Harmonize installation is complete
# You have access to all Harmonize functions and variables

log "Installing additional productivity tools..."

# Install common admin tools based on distribution
case "$OS_ID" in
  debian|ubuntu)
    install_packages htop ncdu tree jq
    ;;
  fedora|rhel|centos)
    install_packages htop ncdu tree jq
    ;;
  arch)
    install_packages htop ncdu tree jq
    ;;
esac

print_success "Productivity tools installed (htop, ncdu, tree, jq)"
