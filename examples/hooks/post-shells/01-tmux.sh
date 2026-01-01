#!/usr/bin/env bash
# Example hook: Install and configure tmux
# Place in: /etc/harmonize/hooks.d/post-shells/

log "Installing and configuring tmux..."

# Install tmux
install_packages tmux

if command -v tmux &>/dev/null; then
  # Create a sensible default tmux config for all users
  local tmux_conf="/etc/tmux.conf"
  
  if [[ ! -f "$tmux_conf" ]]; then
    cat > "$tmux_conf" << 'TMUXCONF'
# Sensible tmux defaults

# Change prefix to Ctrl-a (more ergonomic than Ctrl-b)
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Enable mouse support
set -g mouse on

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when one is closed
set -g renumber-windows on

# Increase scrollback buffer
set -g history-limit 50000

# Enable 256 colors
set -g default-terminal "screen-256color"

# Faster key repetition
set -sg escape-time 0

# Reload config with r
bind r source-file /etc/tmux.conf \; display "Config reloaded!"

# Split panes with | and -
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Navigate panes with vim keys
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Status bar styling
set -g status-style bg=colour235,fg=colour136
set -g status-left "#[fg=green]#S "
set -g status-right "#[fg=yellow]#H #[fg=cyan]%Y-%m-%d %H:%M"
TMUXCONF
    log "Created tmux config at $tmux_conf"
  fi
  
  print_success "tmux installed and configured"
else
  print_warning "tmux installation failed"
fi
