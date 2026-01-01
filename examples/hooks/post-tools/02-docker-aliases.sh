#!/usr/bin/env bash
# Example hook: Add useful Docker aliases after modern tools installation
# Place in: /etc/harmonize/hooks.d/post-tools/

log "Adding Docker convenience aliases..."

# Check if docker is installed
if ! command -v docker >/dev/null 2>&1; then
  log "Docker not found, skipping Docker aliases"
  return 0
fi

# Create a shared alias file
ALIAS_FILE="/etc/profile.d/harmonize-docker-aliases.sh"

if [[ "$DRY_RUN" == "0" ]]; then
  cat > "$ALIAS_FILE" <<'DOCKERALIASES'
# Harmonize Docker Aliases
# Useful shortcuts for Docker operations

# Container management
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dlog='docker logs'
alias dlogf='docker logs -f'
alias dexec='docker exec -it'
alias dstop='docker stop'
alias drm='docker rm'
alias drmf='docker rm -f'

# Image management
alias di='docker images'
alias drmi='docker rmi'
alias dpull='docker pull'
alias dbuild='docker build'

# System cleanup
alias dprune='docker system prune -af'
alias dvprune='docker volume prune -f'
alias dnprune='docker network prune -f'

# Docker Compose shortcuts
alias dc='docker-compose'
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dclogs='docker-compose logs -f'
alias dcps='docker-compose ps'

# Inspection
alias dinspect='docker inspect'
alias dstats='docker stats'
DOCKERALIASES

  chmod +x "$ALIAS_FILE"
  log "Created Docker aliases at: $ALIAS_FILE"
fi

print_success "Docker aliases installed"
