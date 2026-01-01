#!/usr/bin/env bash
# Example hook: Configure automatic security updates
# Place in: /etc/harmonize/hooks.d/post-deps/

log "Configuring automatic security updates..."

case "$OS_ID" in
  debian|ubuntu)
    install_packages unattended-upgrades apt-listchanges

    if [[ "$DRY_RUN" == "0" ]]; then
      # Enable automatic security updates only
      cat > /etc/apt/apt.conf.d/50unattended-upgrades <<'APTCONF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
APTCONF

      cat > /etc/apt/apt.conf.d/20auto-upgrades <<'AUTOCONF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
AUTOCONF

      log "Configured unattended-upgrades for security updates"
    fi
    ;;

  fedora|rhel|centos)
    install_packages dnf-automatic

    if [[ "$DRY_RUN" == "0" ]]; then
      # Configure dnf-automatic for security updates only
      if [[ -f /etc/dnf/automatic.conf ]]; then
        perl -pi -e 's/^upgrade_type = .*/upgrade_type = security/' /etc/dnf/automatic.conf
        perl -pi -e 's/^apply_updates = .*/apply_updates = yes/' /etc/dnf/automatic.conf
      fi

      systemctl enable --now dnf-automatic.timer 2>/dev/null || true
      log "Configured dnf-automatic for security updates"
    fi
    ;;

  arch)
    log "Arch Linux: Manual intervention recommended for updates"
    print_warning "Consider using 'pacman -Syu' regularly or setting up a custom systemd timer"
    ;;
esac

print_success "Automatic security updates configured"
