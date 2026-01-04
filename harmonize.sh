#!/usr/bin/env bash
set -Eeuo pipefail

# ==============================================================================
# PROJECT: Prompt Harmonizer
# FILE: harmonize.sh
# DESCRIPTION: Main installation and configuration script for harmonizing shell environments
#              (Bash + Zsh), prompts (Starship), banners, and tools across distros.
# AUTHOR: Alex (Agentic)
# VERSION: 2.1.0
# DATE: 2026-01-01
# LICENSE: MIT
# ==============================================================================

SCRIPT_VERSION="2.1.0"
STATE_DIR="/var/lib/prompt-harmonizer"
BACKUP_DIR_BASE="/var/backups/prompt-harmonizer"
LOG_FILE="/var/log/prompt-harmonizer.log"

# ---------------- Defaults (customize) ----------------
# These variables control the default behavior of the script.
# They can be overridden by environment variables.

# PROMPT_MODE_DEFAULT: "starship" (rich prompt) or "ps1" (simple standard prompt)
PROMPT_MODE_DEFAULT="starship"

# BANNER_TEXT_DEFAULT: The text displayed in /etc/issue and /etc/issue.net
# Matches config/banner.txt for consistency (with or without internet)
BANNER_TEXT_DEFAULT=$'

             __ __       _         _
            |  \\  \\ _ _ | |   ___ | |_
            |     || | || |_ [_] || . \\
            |_|_|_| \\  ||___|[___||___/
                    [__/                  01/2026

╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║        All activities are logged and monitored            ║
║        Unauthorized access is strictly prohibited         ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
.



'

# Starship config with badges:
# Defines the look and feel of the Starship prompt.
# Includes custom badges for:
# - SSH: shows when in SSH session
# - CT: shows when IN_CONTAINER=1 (Docker/LXC detection)
# - DOCKER: shows current docker context if docker available
# - K8S: shows current kubectl context if kubectl available
# - ROLE: shows ROLE_NAME (from /etc/role or heuristics)
STARSHIP_TOML_DEFAULT=$'# ~/.config/starship.toml\nadd_newline = true\n\nformat = """$username$hostname$custom$directory$git_branch$git_status$cmd_duration\n$character"""\n\n[username]\nshow_always = true\nformat = "[$user]($style) "\nstyle_user = "bold cyan"\nstyle_root = "bold red"\n\n[hostname]\nssh_only = false\nformat = "on [$hostname]($style) "\nstyle = "bold yellow"\n\n# --- Context Badges (custom.*) ---\n[custom.role]\nwhen = """ test -n \\"$ROLE_NAME\\" """\nstyle = "bold white"\nformat = "[ROLE:$output]($style) "\ncommand = "printf \\"%s\\" \\"$ROLE_NAME\\""\n\n[custom.ssh]\nwhen = """ test -n \\"$SSH_CONNECTION\\" """\nstyle = "bold blue"\nformat = "[SSH]($style) "\ncommand = "printf SSH"\n\n[custom.container]\nwhen = """ test -n \\"$IN_CONTAINER\\" """\nstyle = "bold magenta"\nformat = "[CT]($style) "\ncommand = "printf CT"\n\n[custom.docker]\nwhen = """ command -v docker >/dev/null 2>&1 && docker context show >/dev/null 2>&1 """\nstyle = "bold cyan"\nformat = "[DOCKER:$output]($style) "\ncommand = "docker context show 2>/dev/null | head -n1"\n\n[custom.k8s]\nwhen = """ command -v kubectl >/dev/null 2>&1 && kubectl config current-context >/dev/null 2>&1 """\nstyle = "bold green"\nformat = "[K8S:$output]($style) "\ncommand = "kubectl config current-context 2>/dev/null | head -n1"\n\n[directory]\ntruncation_length = 4\ntruncate_to_repo = true\nformat = "in [$path]($style) "\nstyle = "bold green"\n\n[git_branch]\nformat = "[$symbol$branch]($style) "\nsymbol = " "\nstyle = "bold purple"\n\n[git_status]\nformat = "[$all_status$ahead_behind]($style) "\nstyle = "bold purple"\n\n[cmd_duration]\nmin_time = 500\nformat = "took [$duration]($style) "\nstyle = "bold white"\n\n[character]\nsuccess_symbol = "[❯](bold green)"\nerror_symbol = "[❯](bold red)"\n'

# ------------------------------------------------------
# Configuration Initialization
# ------------------------------------------------------
# Load values from environment or use defaults
PROMPT_MODE="${PROMPT_MODE:-$PROMPT_MODE_DEFAULT}"
BANNER_TEXT="${BANNER_TEXT:-$BANNER_TEXT_DEFAULT}"
STARSHIP_TOML="${STARSHIP_TOML:-$STARSHIP_TOML_DEFAULT}"
KEYBOARD_LAYOUT="${KEYBOARD_LAYOUT:-}"       # e.g., "fr" or "us"
HARMONIZE_LANG="${HARMONIZE_LANG:-}"         # "en" or "fr"
INSTALL_MODERN_TOOLS="${INSTALL_MODERN_TOOLS:-0}" # Set to 1 to install zoxide, fzf, etc.

# Parse args (including --dry-run and --interactive)
DRY_RUN=0
INTERACTIVE=0
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --interactive|-i) INTERACTIVE=1; shift ;;
    --keyboard|-k) KEYBOARD_LAYOUT="$2"; shift 2 ;;
    --lang|-l) HARMONIZE_LANG="$2"; shift 2 ;;
    --modern-tools|-m) INSTALL_MODERN_TOOLS=1; shift ;;
    *) POSITIONAL_ARGS+=("$1"); shift ;;
  esac
done
set -- "${POSITIONAL_ARGS[@]}"
ACTION="${1:-install}"

CONFIGURE_SSH_BANNER="${CONFIGURE_SSH_BANNER:-1}" # Should we configure /etc/ssh/sshd_config?
ENABLE_ZSH="${ENABLE_ZSH:-1}"                     # Apply config to Zsh?
ENABLE_BASH="${ENABLE_BASH:-1}"                   # Apply config to Bash?
USE_DYNAMIC_BANNER="${USE_DYNAMIC_BANNER:-1}"     # Use dynamic MOTD script?

# Optional external config support:
# If set, script will try to download banner.txt and starship.toml from this URL base.
# Default: Uses the official axlcorp/harmonize repository
# Set to empty string to disable: CONFIG_URL_BASE=""
: "${CONFIG_URL_BASE=https://raw.githubusercontent.com/axlcorp/harmonize/refs/heads/main/config}"

# ------- Internationalization (i18n) -------
init_messages() {
  # Auto-detect lang if not set
  if [[ -z "$HARMONIZE_LANG" ]]; then
    local sys_lang="${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}"
    if [[ "$sys_lang" == *"fr_"* ]]; then
      HARMONIZE_LANG="fr"
    else
      HARMONIZE_LANG="en"
    fi
  fi

  # Default English
  MSG_HEADER="Installation in progress..."
  MSG_DEPS_CHECK="Checking system dependencies..."
  MSG_DEPS_OK="Dependencies installed"
  MSG_BANNERS_APPLY="Applying system banners..."
  MSG_BANNERS_DONE="Banners applied"
  MSG_BANNERS_DYN_OK="Dynamic banners installed (MOTD)"
  MSG_KEYBOARD_CFG="Configuring keyboard..."
  MSG_KEYBOARD_OK="Keyboard configured"
  MSG_SSH_CFG="Configuring SSH banner..."
  MSG_SSH_OK="SSH banner configured"
  MSG_SSH_SKIP="SSH banner ignored (CONFIGURE_SSH_BANNER=0)"
  MSG_STARSHIP_INSTALL="Installing Starship..."
  MSG_STARSHIP_OK="Starship installed"
  MSG_SHELLS_CFG="Configuring shells (Bash + Zsh)..."
  MSG_SHELLS_DONE="Shell configuration applied"
  MSG_USER_CFG="Deploying per-user Starship config..."
  MSG_USER_DONE="User configuration deployed"
  MSG_INSTALL_SUCCESS="Installation completed successfully!"
  MSG_RESTART_HINT_1="To verify changes:"
  MSG_RESTART_HINT_2="• Reconnect via SSH"
  MSG_RESTART_HINT_3="• Or open a new shell"

  # Wizard
  MSG_WIZ_TITLE="Interactive Configuration"
  MSG_WIZ_PROMPT_MODE="Prompt Mode"
  MSG_WIZ_DYN_BANNER="Enable Dynamic Banners (MOTD)?"
  MSG_WIZ_SSH_BANNER="Configure SSH Banner?"
  MSG_WIZ_BASH="Configure Bash?"
  MSG_WIZ_ZSH="Configure Zsh?"
  MSG_WIZ_MODERN="Install Modern Shell Tools (zoxide, fzf, eza, bat)?"
  MSG_WIZ_KB_ASK="Change keyboard layout?"
  MSG_WIZ_KB_LAYOUT="Keyboard Layout (e.g. fr, us)"
  MSG_WIZ_SUMMARY="Configuration Summary:"
  MSG_WIZ_CONTINUE="Press Enter to continue or Ctrl+C to cancel..."
  MSG_MODERN_INSTALL="Installing modern shell tools..."
  MSG_MODERN_OK="Modern shell tools installed"

  # French Overrides
  if [[ "$HARMONIZE_LANG" == "fr" ]]; then
    MSG_HEADER="Installation en cours..."
    MSG_DEPS_CHECK="Vérification des dépendances système..."
    MSG_DEPS_OK="Dépendances installées"
    MSG_BANNERS_APPLY="Application des banners système..."
    MSG_BANNERS_DONE="Banners appliqués"
    MSG_BANNERS_DYN_OK="Banners dynamiques installés (MOTD)"
    MSG_KEYBOARD_CFG="Configuration du clavier..."
    MSG_KEYBOARD_OK="Clavier configuré"
    MSG_SSH_CFG="Configuration du banner SSH..."
    MSG_SSH_OK="Banner SSH configuré"
    MSG_SSH_SKIP="Banner SSH ignoré (CONFIGURE_SSH_BANNER=0)"
    MSG_STARSHIP_INSTALL="Installation de Starship..."
    MSG_STARSHIP_OK="Starship installé"
    MSG_SHELLS_CFG="Configuration des shells (Bash + Zsh)..."
    MSG_SHELLS_DONE="Configuration shells appliquée"
    MSG_USER_CFG="Déploiement config Starship par utilisateur..."
    MSG_USER_DONE="Configuration utilisateurs déployée"
    MSG_INSTALL_SUCCESS="Installation terminée avec succès!"
    MSG_RESTART_HINT_1="Pour activer les changements :"
    MSG_RESTART_HINT_2="• Reconnectez-vous en SSH"
    MSG_RESTART_HINT_3="• Ou ouvrez un nouveau shell"
    
    MSG_WIZ_TITLE="Configuration Interactive"
    MSG_WIZ_PROMPT_MODE="Mode du Prompt"
    MSG_WIZ_DYN_BANNER="Activer les Banners Dynamiques (MOTD) ?"
    MSG_WIZ_SSH_BANNER="Configurer le Banner SSH ?"
    MSG_WIZ_BASH="Configurer Bash ?"
    MSG_WIZ_ZSH="Configurer Zsh ?"
    MSG_WIZ_MODERN="Installer le Modern Shell Pack (zoxide, fzf, eza, bat) ?"
    MSG_WIZ_KB_ASK="Changer la configuration du clavier ?"
    MSG_WIZ_KB_LAYOUT="Layout Clavier (ex: fr, us)"
    MSG_WIZ_SUMMARY="Résumé de la configuration :"
    MSG_WIZ_CONTINUE="Appuyez sur Entrée pour continuer ou Ctrl+C pour annuler..."
    MSG_MODERN_INSTALL="Installation du Modern Shell Pack..."
    MSG_MODERN_OK="Modern Shell Pack installé"
  fi
}

# ------- Utilities -------
log() {
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "[$(date -Is)] $*" >&2
  else
    echo "[$(date -Is)] $*" | tee -a "$LOG_FILE" >&2
  fi
}

# ------- Pretty Output Functions -------
# Colors (using $'...' for proper ANSI escape interpretation)
C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'
C_DIM=$'\033[2m'
C_RED=$'\033[0;31m'
C_GREEN=$'\033[0;32m'
C_YELLOW=$'\033[0;33m'
C_BLUE=$'\033[0;34m'
C_MAGENTA=$'\033[0;35m'
C_CYAN=$'\033[0;36m'
C_WHITE=$'\033[0;37m'
C_BOLD_GREEN=$'\033[1;32m'
C_BOLD_BLUE=$'\033[1;34m'
C_BOLD_YELLOW=$'\033[1;33m'
C_BOLD_RED=$'\033[1;31m'
C_BOLD_CYAN=$'\033[1;36m'

# Check if terminal supports colors
if [[ ! -t 1 ]]; then
  C_RESET='' C_BOLD='' C_DIM='' C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_MAGENTA='' C_CYAN='' C_WHITE=''
  C_BOLD_GREEN='' C_BOLD_BLUE='' C_BOLD_YELLOW='' C_BOLD_RED='' C_BOLD_CYAN=''
fi

# Box drawing
print_box_top() {
  local width=${1:-60}
  printf "${C_BOLD_BLUE}╔"
  printf '═%.0s' $(seq 1 $((width - 2)))
  printf "╗${C_RESET}\n"
}

print_box_bottom() {
  local width=${1:-60}
  printf "${C_BOLD_BLUE}╚"
  printf '═%.0s' $(seq 1 $((width - 2)))
  printf "╝${C_RESET}\n"
}

print_box_line() {
  local text="$1"
  local width=${2:-60}
  local text_len=${#text}
  local padding=$(( (width - text_len - 4) / 2 ))
  local extra=$(( (width - text_len - 4) % 2 ))

  printf "${C_BOLD_BLUE}║${C_RESET} "
  printf ' %.0s' $(seq 1 $padding)
  printf "${C_BOLD}%s${C_RESET}" "$text"
  printf ' %.0s' $(seq 1 $((padding + extra)))
  printf " ${C_BOLD_BLUE}║${C_RESET}\n"
}

print_box_empty() {
  local width=${1:-60}
  printf "${C_BOLD_BLUE}║${C_RESET}"
  printf ' %.0s' $(seq 1 $((width - 2)))
  printf "${C_BOLD_BLUE}║${C_RESET}\n"
}

print_header() {
  local width=60
  echo ""
  print_box_top $width
  print_box_empty $width
  print_box_line "🎨 Prompt Harmonizer v${SCRIPT_VERSION}" $width
  print_box_empty $width
  print_box_line "$1" $width
  print_box_empty $width
  print_box_bottom $width
  echo ""
}

print_step() {
  local current=$1
  local total=$2
  local message=$3
  printf "${C_BOLD_CYAN}[%d/%d]${C_RESET} %s\n" "$current" "$total" "$message"
}

print_success() {
  printf "${C_BOLD_GREEN}✓${C_RESET} %s\n" "$1"
}

print_warning() {
  printf "${C_BOLD_YELLOW}⚠${C_RESET}  %s\n" "$1"
}

print_error() {
  printf "${C_BOLD_RED}✗${C_RESET} %s\n" "$1"
}

print_info() {
  printf "${C_BOLD_BLUE}ℹ${C_RESET}  %s\n" "$1"
}

run_cmd() {
  if [[ "$DRY_RUN" == "1" ]]; then
    print_info "[DRY-RUN] Exec: $*"
  else
    "$@"
  fi
}

print_summary_header() {
  echo ""
  printf "${C_BOLD_GREEN}════════════════════════════════════════════════════════════${C_RESET}\n"
  printf "${C_BOLD_GREEN}                    Installation Summary                     ${C_RESET}\n"
  printf "${C_BOLD_GREEN}════════════════════════════════════════════════════════════${C_RESET}\n"
  echo ""
}

# Check for root privileges
# Most operations (installing packages, modifying /etc) require root.
need_root() {
  [[ "$DRY_RUN" == "1" ]] && return 0
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    print_error "This script must be run as root or with sudo"
    echo ""
    echo "Usage:"
    echo "  sudo bash harmonize.sh install"
    echo "  curl -fsSL <url>/harmonize.sh | sudo bash -s -- install"
    exit 1
  fi
}

# Verify system prerequisites
check_prerequisites() {
  local missing=()

  # Check for required commands
  local required_cmds=("curl" "perl" "mktemp" "tee")
  for cmd in "${required_cmds[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    print_error "Missing required commands: ${missing[*]}"
    print_info "Please install them first, then retry"
    return 1
  fi

  # Check for sufficient disk space in /var (at least 100MB)
  if command -v df >/dev/null 2>&1; then
    local available_kb
    available_kb=$(df /var 2>/dev/null | awk 'NR==2 {print $4}')
    if [[ -n "$available_kb" ]] && [[ "$available_kb" -lt 102400 ]]; then
      print_warning "Low disk space in /var: $(( available_kb / 1024 ))MB available"
      print_info "At least 100MB recommended for backups and logs"
    fi
  fi

  # Check internet connectivity (for downloads)
  if [[ "$DRY_RUN" == "0" ]]; then
    if ! curl -fsSL --max-time 5 https://starship.rs >/dev/null 2>&1; then
      print_warning "Internet connectivity check failed"
      print_info "Some features may not work without internet access"
    fi
  fi

  return 0
}

# Detect Operating System and Package Manager
# Sets OS_ID (ubuntu, debian, fedora, arch...) and PKG_MGR (apt, dnf, pacman).
detect_os() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_LIKE="${ID_LIKE:-}"
  else
    OS_ID="unknown"; OS_LIKE=""
  fi
  
  # Detect Package Manager
  PKG_MGR="unknown"
  if command -v apt-get >/dev/null; then PKG_MGR="apt";
  elif command -v dnf >/dev/null; then PKG_MGR="dnf";
  elif command -v pacman >/dev/null; then PKG_MGR="pacman";
  fi
  
  log "OS Detected: $OS_ID ($OS_LIKE) | Package Manager: $PKG_MGR"
}

install_packages() {
  local pkgs=("$@")
  [[ ${#pkgs[@]} -eq 0 ]] && { log "ERROR: install_packages called with no packages"; return 1; }

  if [[ "$DRY_RUN" == "1" ]]; then
    print_info "[DRY-RUN] Install packages: ${pkgs[*]}"
    return 0
  fi

  log "Installing packages: ${pkgs[*]}"

  case "$PKG_MGR" in
    apt)
      export DEBIAN_FRONTEND=noninteractive
      if ! apt-get update -y 2>&1 | tee -a "$LOG_FILE"; then
        print_error "Failed to update package lists"
        return 1
      fi
      if ! apt-get install -y --no-install-recommends "${pkgs[@]}" 2>&1 | tee -a "$LOG_FILE"; then
        print_error "Failed to install packages: ${pkgs[*]}"
        return 1
      fi
      ;;
    dnf)
      if ! dnf install -y "${pkgs[@]}" 2>&1 | tee -a "$LOG_FILE"; then
        print_error "Failed to install packages: ${pkgs[*]}"
        return 1
      fi
      ;;
    pacman)
      if ! pacman -S --noconfirm "${pkgs[@]}" 2>&1 | tee -a "$LOG_FILE"; then
        print_error "Failed to install packages: ${pkgs[*]}"
        return 1
      fi
      ;;
    *)
      print_warning "No supported package manager found ($PKG_MGR). Install manually: ${pkgs[*]}"
      return 1
      ;;
  esac

  log "Successfully installed: ${pkgs[*]}"
  return 0
}

backup_file() {
  local src="$1" backup_dir="$2"

  # Validate inputs
  [[ -z "$src" ]] && { log "ERROR: backup_file called with empty source"; return 1; }
  [[ -z "$backup_dir" ]] && { log "ERROR: backup_file called with empty backup_dir"; return 1; }

  # Skip if source doesn't exist
  [[ -e "$src" ]] || return 0

  if [[ "$DRY_RUN" == "1" ]]; then
    print_info "[DRY-RUN] Backup $src -> $backup_dir/"
    return 0
  fi

  # Create backup directory with error checking
  if ! mkdir -p "$backup_dir"; then
    print_error "Failed to create backup directory: $backup_dir"
    return 1
  fi

  # Perform backup with error checking
  if ! cp -a "$src" "$backup_dir/"; then
    print_error "Failed to backup $src to $backup_dir/"
    return 1
  fi

  log "Backup: $src -> $backup_dir/"
  return 0
}

write_file_atomic() {
  local dest="$1" content="$2"

  # Validate inputs
  [[ -z "$dest" ]] && { log "ERROR: write_file_atomic called with empty destination"; return 1; }

  if [[ "$DRY_RUN" == "1" ]]; then
    print_info "[DRY-RUN] Write to $dest (${#content} bytes)"
    return 0
  fi

  # Create temporary file with error checking
  local tmp
  if ! tmp="$(mktemp)"; then
    print_error "Failed to create temporary file"
    return 1
  fi

  # Write content with error checking
  if ! printf '%s' "$content" > "$tmp"; then
    print_error "Failed to write content to temporary file"
    rm -f "$tmp"
    return 1
  fi

  # Set permissions
  if ! chmod 0644 "$tmp"; then
    print_warning "Failed to set permissions on temporary file"
  fi

  # Atomic move with error checking
  if ! mv "$tmp" "$dest"; then
    print_error "Failed to move temporary file to destination: $dest"
    rm -f "$tmp"
    return 1
  fi

  return 0
}

ensure_state_dirs() {
  if [[ "$DRY_RUN" == "1" ]]; then
    print_info "[DRY-RUN] Ensure state dirs and log file"
    return 0
  fi
  mkdir -p "$STATE_DIR" "$BACKUP_DIR_BASE"
  touch "$LOG_FILE"
  chmod 0600 "$LOG_FILE" || true
}

# ------- Rollback support -------
ROLLBACK_DIR=""
rollback() {
  local code=$?
  if [[ $code -ne 0 && -n "$ROLLBACK_DIR" && -d "$ROLLBACK_DIR" ]]; then
    log "ERROR detected. Rolling back from $ROLLBACK_DIR ..."
    for f in "$ROLLBACK_DIR"/*; do
      [[ -e "$f" ]] || continue
      local base; base="$(basename "$f")"
      case "$base" in
        issue|issue.net|bash.bashrc|zshrc|sshd_config)
          cp -a "$f" "/etc/$base" || true
          ;;
      esac
    done
    log "Rollback completed."
  fi
  exit "$code"
}
trap rollback EXIT

# ------- Extensible Hooks System -------
HOOKS_DIR="${HOOKS_DIR:-/etc/harmonize/hooks.d}"

# Available hooks:
#   pre-install    - Before any installation starts
#   post-deps      - After dependencies are installed
#   post-banners   - After banners are configured
#   post-tools     - After modern tools are installed
#   post-starship  - After Starship is installed
#   post-shells    - After shell configs are applied
#   post-install   - After complete installation
#   pre-uninstall  - Before uninstallation starts
#   post-uninstall - After uninstallation completes

run_hooks() {
  local hook_name="$1"
  local hook_dir="$HOOKS_DIR/$hook_name"
  
  [[ -d "$hook_dir" ]] || return 0
  
  local scripts=("$hook_dir"/*.sh)
  [[ -e "${scripts[0]}" ]] || return 0
  
  log "Running hooks: $hook_name"
  
  for script in "${scripts[@]}"; do
    [[ -f "$script" ]] || continue
    local script_name
    script_name="$(basename "$script")"
    
    if [[ "$DRY_RUN" == "1" ]]; then
      print_info "[DRY-RUN] Would run hook: $hook_name/$script_name"
    else
      if [[ -x "$script" ]]; then
        log "Executing hook: $script"
        # Source the script to give it access to all functions and variables
        # shellcheck disable=SC1090
        if ! source "$script"; then
          print_warning "Hook failed: $hook_name/$script_name (continuing...)"
          log "WARNING: Hook $script exited with error"
        fi
      else
        log "Skipping non-executable hook: $script"
      fi
    fi
  done
}

ensure_hooks_dir() {
  if [[ "$DRY_RUN" == "1" ]]; then
    print_info "[DRY-RUN] Would create hooks directory structure"
    return 0
  fi
  
  local hook_names=("pre-install" "post-deps" "post-banners" "post-tools" "post-starship" "post-shells" "post-install" "pre-uninstall" "post-uninstall")
  
  for hook in "${hook_names[@]}"; do
    mkdir -p "$HOOKS_DIR/$hook"
  done
  
  # Create README for hooks
  if [[ ! -f "$HOOKS_DIR/README.md" ]]; then
    cat > "$HOOKS_DIR/README.md" << 'HOOKREADME'
# Harmonize Hooks

Place executable `.sh` scripts in the appropriate subdirectory to extend Harmonize.

## Available Hooks

| Hook | When it runs |
|------|--------------|
| `pre-install/` | Before any installation starts |
| `post-deps/` | After dependencies are installed |
| `post-banners/` | After banners are configured |
| `post-tools/` | After modern tools are installed |
| `post-starship/` | After Starship is installed |
| `post-shells/` | After shell configs are applied |
| `post-install/` | After complete installation |
| `pre-uninstall/` | Before uninstallation starts |
| `post-uninstall/` | After uninstallation completes |

## Example Hook

```bash
#!/usr/bin/env bash
# /etc/harmonize/hooks.d/post-install/install-neovim.sh

# This runs after Harmonize installation
install_packages neovim

# You have access to all Harmonize functions:
# - install_packages <pkg>...
# - log "message"
# - print_success/print_info/print_warning/print_error
# - run_cmd <command>
# - $OS_ID, $PKG_MGR, $DRY_RUN, etc.
```

Make your hooks executable: `chmod +x your-hook.sh`
HOOKREADME
    log "Created hooks README at $HOOKS_DIR/README.md"
  fi
}

# ------- Managed block helpers -------
strip_managed_block() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  if [[ "$DRY_RUN" == "1" ]]; then
    print_info "[DRY-RUN] Would strip managed block from $file"
    return 0
  fi
  perl -0777 -pe 's/\n# >>> prompt-harmonizer.*?# <<< prompt-harmonizer <<<\n//s' -i "$file"
}
append_managed_block() {
  local file="$1" block="$2"
  if [[ "$DRY_RUN" == "1" ]]; then
    print_info "[DRY-RUN] Would append managed block to $file"
    return 0
  fi
  touch "$file"
  strip_managed_block "$file"
  printf '\n%s\n' "$block" >> "$file"
}

# ------- Container detection + role detection -------
container_and_role_detect_snippet() {
  cat <<'EOF'
# >>> prompt-harmonizer (env-detect) >>>
# Best-effort container detection for prompt badges
if [[ -z "${IN_CONTAINER:-}" ]]; then
  if [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]] || [[ -f /run/systemd/container ]]; then
    export IN_CONTAINER=1
  elif [[ -r /proc/1/cgroup ]] && grep -Eqi '(docker|lxc|kubepods|containerd)' /proc/1/cgroup; then
    export IN_CONTAINER=1
  elif [[ -r /proc/1/environ ]] && tr '\0' '\n' </proc/1/environ 2>/dev/null | grep -Eq '^container='; then
    export IN_CONTAINER=1
  fi
fi

# ROLE detection:
# Priority: /etc/role (single word like: pve, docker, k8s, prod, lab, etc.)
# Fallback: heuristics (best-effort)
if [[ -z "${ROLE_NAME:-}" ]]; then
  if [[ -r /etc/role ]]; then
    ROLE_NAME="$(head -n1 /etc/role | tr -d '\r' | xargs)"
    export ROLE_NAME
  else
    # Heuristics
    if command -v pveversion >/dev/null 2>&1 || [[ -d /etc/pve ]]; then
      export ROLE_NAME="pve"
    elif [[ -S /var/run/docker.sock ]] || [[ -S /run/docker.sock ]] || command -v dockerd >/dev/null 2>&1; then
      export ROLE_NAME="docker"
    elif command -v kubelet >/dev/null 2>&1 || [[ -f /etc/kubernetes/kubelet.conf ]]; then
      export ROLE_NAME="k8s"
    else
      # leave unset
      :
    fi
  fi
fi
# <<< prompt-harmonizer <<<
EOF
}

bash_snippet_starship() {
  cat <<'EOF'
# --- Harmonize: Starship & Modern Tools ---
# Ensure path
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
  export PATH=$PATH:/usr/local/bin
fi

# Modern Tools (if installed)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
  alias cd='z'
fi
if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza --icons --group-directories-first -l'
  alias la='eza --icons --group-directories-first -la'
fi
if command -v batcat &>/dev/null; then
  alias cat='batcat'
elif command -v bat &>/dev/null; then
  alias cat='bat'
fi
if command -v fzf &>/dev/null; then
  [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
  [ -f /usr/share/bash-completion/completions/fzf ] && source /usr/share/bash-completion/completions/fzf
fi

# Starship init
if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi
# ------------------------------------------
EOF
}

zsh_snippet_starship() {
  cat <<'EOF'
# --- Harmonize: Starship & Modern Tools ---
# Ensure path
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
  export PATH=$PATH:/usr/local/bin
fi

# Modern Tools (if installed)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi
if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza --icons --group-directories-first -l'
  alias la='eza --icons --group-directories-first -la'
fi
if command -v batcat &>/dev/null; then
  alias cat='batcat'
elif command -v bat &>/dev/null; then
  alias cat='bat'
fi
# fzf usually installs keybindings in zsh via separate script or integration, minimal check here:
if command -v fzf &>/dev/null; then
  [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
  [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
fi

if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
# ------------------------------------------
EOF
}

bash_snippet_ps1() {
  cat <<'EOF'
# >>> prompt-harmonizer (ps1) >>>
# Managed by prompt-harmonizer. Do not edit inside.
if [[ $EUID -eq 0 ]]; then
  PS1='\[\e[1;31m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]# '
else
  PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]$ '
fi
# <<< prompt-harmonizer <<<
EOF
}

zsh_snippet_ps1() {
  cat <<'EOF'
# >>> prompt-harmonizer (ps1) >>>
# Managed by prompt-harmonizer. Do not edit inside.
autoload -Uz colors && colors
if [[ $EUID -eq 0 ]]; then
  PROMPT='%{$fg[red]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%}# '
else
  PROMPT='%{$fg[green]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%}$ '
fi
# <<< prompt-harmonizer <<<
EOF
}

# ------- Per-user starship config -------
ensure_user_starship_config() {
  local user_home="$1" user_name="$2"
  local cfg_dir="$user_home/.config"
  local cfg_file="$cfg_dir/starship.toml"
  if [[ "$DRY_RUN" == "1" ]]; then
    print_info "[DRY-RUN] Ensure dir $cfg_dir"
  else
    mkdir -p "$cfg_dir"
  fi
  if [[ ! -f "$cfg_file" || "${FORCE_STARSHIP_CONFIG:-0}" == "1" ]]; then
    if [[ "$DRY_RUN" == "1" ]]; then
      print_info "[DRY-RUN] Write Starship config for $user_name"
    else
      printf '%s' "$STARSHIP_TOML" > "$cfg_file"
      chown -R "$user_name":"$user_name" "$cfg_dir"
      chmod 0644 "$cfg_file"
    fi
    if [[ "${FORCE_STARSHIP_CONFIG:-0}" == "1" ]]; then
      log "Updated Starship config for $user_name: $cfg_file"
    else
      log "Created Starship config for $user_name: $cfg_file"
    fi
  else
    log "Starship config exists for $user_name (kept): $cfg_file"
  fi
}

apply_starship_per_user() {
  while IFS=: read -r name _ uid _ _ home _; do
    [[ -n "$name" && -n "$uid" ]] || continue
    if [[ "$name" == "root" || ( "$uid" -ge 1000 && "$uid" -lt 65534 ) ]]; then
      [[ -d "$home" ]] || continue
      ensure_user_starship_config "$home" "$name"
    fi
  done < /etc/passwd
}

# ------- Modular Tool System -------
install_tool() {
  local name="$1"
  local binary_check="$2"
  local install_cmd="$3"
  local version_cmd="$4"

  # Validate inputs
  [[ -z "$name" ]] && { log "ERROR: install_tool called with empty name"; return 1; }
  [[ -z "$binary_check" ]] && { log "ERROR: install_tool called with empty binary_check"; return 1; }
  [[ -z "$install_cmd" ]] && { log "ERROR: install_tool called with empty install_cmd"; return 1; }

  log "Checking $name..."
  if command -v "$binary_check" >/dev/null 2>&1; then
    local current_version
    current_version=$($version_cmd 2>/dev/null | head -n1 || echo "unknown")
    log "$name already installed: $current_version"
    return 0
  fi

  log "Installing $name..."
  if [[ "$DRY_RUN" == "0" ]]; then
    # Execute install command with error handling
    if ! eval "$install_cmd" 2>&1 | tee -a "$LOG_FILE"; then
      print_error "$name installation command failed"
      return 1
    fi

    # Verify installation succeeded
    if ! command -v "$binary_check" >/dev/null 2>&1; then
      print_error "$name install failed: binary '$binary_check' not found after installation"
      return 1
    fi

    local installed_version
    installed_version=$($version_cmd 2>/dev/null | head -n1 || echo "unknown")
    log "$name installed successfully: $installed_version"
  else
    print_info "[DRY-RUN] Would execute: $install_cmd"
  fi

  return 0
}

configure_shell() {
  local shell_name="$1"     # bash or zsh
  local config_file="$2"
  local snippet_content="$3"
  
  [[ -z "$snippet_content" ]] && return 0
  
  # Check enable flag
  local enable_var="ENABLE_${shell_name^^}"
  [[ "${!enable_var}" == "1" ]] || { log "$enable_var=0 => skipped $shell_name config."; return 0; }

  log "Configuring $shell_name ($config_file)..."
  
  # Backup
  backup_file "$config_file" "$BACKUP_DIR_BASE/current_backup" # We will set BACKUP_DIR_BASE/current_backup later
  
  # Ensure file exists
  if [[ ! -f "$config_file" ]]; then
     run_cmd touch "$config_file"
  fi

  # Append Managed Block
  append_managed_block "$config_file" "$snippet_content"
  log "Applied configuration to $config_file"
}

# ------- Keyboard Configuration -------
configure_keyboard() {
  [[ -n "$KEYBOARD_LAYOUT" ]] || return 0
  
  log "Configuring keyboard layout to '$KEYBOARD_LAYOUT'..."
  
  # Try localectl (systemd)
  if command -v localectl >/dev/null 2>&1; then
    run_cmd localectl set-keymap "$KEYBOARD_LAYOUT"
    log "Applied keymap via localectl"
    return 0
  fi
  
  # Fallback for Debian/Ubuntu without localectl or if it failed
  if [[ -f /etc/default/keyboard ]]; then
    backup_file "/etc/default/keyboard" "$BACKUP_DIR_BASE/current_backup"
    if [[ "$DRY_RUN" == "1" ]]; then
      print_info "[DRY-RUN] Would update GK_LAYOUT in /etc/default/keyboard"
    else
      perl -pi -e "s/^XKBLAYOUT=.*/XKBLAYOUT=\"$KEYBOARD_LAYOUT\"/" /etc/default/keyboard
    fi
    
    if command -v setupcon >/dev/null 2>&1; then
      run_cmd setupcon
    fi
    log "Applied keymap via /etc/default/keyboard"
    return 0
  fi
  
  log "WARNING: Could not configure keyboard (localectl not found)"
}

# ------- Install/Uninstall starship (legacy wrapper) -------
install_modern_tools() {
  local packages=()
  
  if [[ "$OS_ID" == "ubuntu" ]] || [[ "$OS_ID" == "debian" ]]; then
    packages=("zoxide" "fzf" "bat" "eza")
    # If eza not found (older debian/ubuntu without proper repo), fallback to ignore? 
    # Actually, apt install eza works on recent Ubuntu (23.10+). For older, it might fail.
    # We will try to install all.
  elif [[ "$OS_ID" == "fedora" ]] || [[ "$OS_ID" == "rhel" ]] || [[ "$OS_ID" == "centos" ]]; then
    packages=("zoxide" "fzf" "bat" "eza") 
  elif [[ "$OS_ID" == "arch" ]]; then
    packages=("zoxide" "fzf" "bat" "eza")
  fi

  # Attempt installation
  if [[ ${#packages[@]} -gt 0 ]]; then
     install_packages "${packages[@]}"
     # On Debian/Ubuntu bat is installed as batcat
     if [[ "$DRY_RUN" == "0" ]]; then
       if [[ -x "$(command -v batcat)" ]] && [[ ! -x "$(command -v bat)" ]]; then
         # Create symlink for consistency? Or just use alias.
         # For safety, let's just alias in shell config, but we could try symlinking per user bin.
         # Actually alias is safer.
         true 
       fi
     fi
  fi
}

install_starship() {
  install_tool "Starship" "starship" "curl -fsSL --retry 3 https://starship.rs/install.sh | sh -s -- -y -b /usr/local/bin >/dev/null 2>&1" "starship --version"
}

uninstall_starship_if_installed_by_us() {
  if [[ -x /usr/local/bin/starship ]]; then
    rm -f /usr/local/bin/starship
    log "Removed /usr/local/bin/starship"
  else
    log "Starship not found in /usr/local/bin (not removed)."
  fi
}

# ------- Banners -------
apply_banners() {
  local backup_dir="$1"
  backup_file "/etc/issue" "$backup_dir"
  backup_file "/etc/issue.net" "$backup_dir"
  write_file_atomic "/etc/issue" "$BANNER_TEXT"
  write_file_atomic "/etc/issue.net" "$BANNER_TEXT"
  log "Applied banners to /etc/issue and /etc/issue.net"
}

ensure_sshd_uses_issue_net() {
  local backup_dir="$1"
  [[ -f /etc/ssh/sshd_config ]] || { log "No sshd_config; skipped SSH banner."; return 0; }
  backup_file "/etc/ssh/sshd_config" "$backup_dir"
  if grep -Eq '^\s*Banner\s+' /etc/ssh/sshd_config; then
    if [[ "$DRY_RUN" == "1" ]]; then
      print_info "[DRY-RUN] Would update Banner in /etc/ssh/sshd_config"
    else
      perl -pi -e 's/^\s*Banner\s+.*/Banner \/etc\/issue.net/' /etc/ssh/sshd_config
    fi
  else
    if [[ "$DRY_RUN" == "1" ]]; then
      print_info "[DRY-RUN] Would append Banner to /etc/ssh/sshd_config"
    else
      echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
    fi
  fi
  if command -v systemctl >/dev/null 2>&1; then
    run_cmd systemctl reload ssh || run_cmd systemctl reload sshd || true
  fi
  log "Ensured sshd Banner /etc/issue.net"
}

# ------- Dynamic Banner System -------
install_dynamic_banner() {
  local backup_dir="$1"

  # Check if custom generator was loaded by maybe_load_external_config
  local banner_script_content="${CUSTOM_BANNER_GENERATOR:-}"

  # Use built-in default if no custom generator
  if [[ -z "$banner_script_content" ]]; then
    banner_script_content='#!/usr/bin/env bash
# Dynamic Banner Generator - Modern Dashboard

# Colors
C_RESET="\e[0m"
C_BOLD="\e[1m"
C_GREEN="\e[32m"
C_YELLOW="\e[33m"
C_RED="\e[31m"
C_BLUE="\e[34m"
C_DIM="\e[2m"

get_color_scale() {
    local val=$1
    if (( val > 90 )); then echo "$C_RED"; elif (( val > 75 )); then echo "$C_YELLOW"; else echo "$C_GREEN"; fi
}

draw_bar() {
    local percent=$1
    local width=10
    local filled=$(( (percent * width) / 100 ))
    local empty=$(( width - filled ))
    local color=$(get_color_scale "$percent")
    printf "${C_BOLD}[${color}"
    for ((i=0; i<filled; i++)); do printf "|"; done
    printf "${C_DIM}"
    for ((i=0; i<empty; i++)); do printf "."; done
    printf "${C_RESET}${C_BOLD}]${C_RESET}"
}

# Info
os_info=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d"\"" -f2)
[[ -z "$os_info" ]] && os_info=$(grep "^NAME=" /etc/os-release 2>/dev/null | cut -d"\"" -f2)
hostname=$(hostname)
ip_addr=$(hostname -I 2>/dev/null | awk "{print \$1}")
[[ -z "$ip_addr" ]] && ip_addr=$(ip -4 addr show 2>/dev/null | grep -oP "(?<=inet\s)\d+(\.\d+){3}" | grep -v "127.0.0.1" | head -n1)
uptime_info=$(uptime -p 2>/dev/null | sed "s/up //")
load_avg=$(cat /proc/loadavg 2>/dev/null | awk "{print \$1\" \"\$2\" \"\$3}")

# Role
role="server"
[[ -f /etc/role ]] && role=$(head -n1 /etc/role | tr -d "\r\n")

# Mem
mem_total=$(free | grep -i Mem: | awk "{print \$2}")
mem_used=$(free | grep -i Mem: | awk "{print \$3}")
if [[ "$mem_total" -gt 0 ]]; then
    mem_percent=$(( (mem_used * 100) / mem_total ))
else
    mem_percent=0
fi
mem_bar=$(draw_bar "$mem_percent")

# Disk
disk_info=$(df / 2>/dev/null | tail -n1)
disk_percent=$(echo "$disk_info" | awk "{print \$5}" | tr -d "%")
disk_bar=$(draw_bar "$disk_percent")

# Layout
echo ""
printf " ${C_BOLD}${C_BLUE}%-10s${C_RESET} %-30s ${C_BOLD}${C_BLUE}%-10s${C_RESET} %-20s\n" "🖥  OS:" "${os_info:0:28}" "⏱  Uptime:" "${uptime_info:0:20}"
printf " ${C_BOLD}${C_BLUE}%-10s${C_RESET} %-30s ${C_BOLD}${C_BLUE}%-10s${C_RESET} %-20s\n" "🏠 Host:" "${hostname:0:28}" "💡 IP:" "${ip_addr:0:20}"
printf " ${C_BOLD}${C_BLUE}%-10s${C_RESET} %-30s ${C_BOLD}${C_BLUE}%-10s${C_RESET} %-20s\n" "🏷  Role:" "${role:0:28}" "🧠 Load:" "${load_avg:0:20}"
echo ""
printf " ${C_BOLD}${C_BLUE}%-10s${C_RESET} %s %3d%%          ${C_BOLD}${C_BLUE}%-10s${C_RESET} %s %3d%%\n" "💾 Mem:" "$mem_bar" "$mem_percent" "💽 Disk /:" "$disk_bar" "$disk_percent"
echo ""
'
  fi

  # Install banner generator script
  write_file_atomic "/usr/local/bin/harmonize-banner" "$banner_script_content"
  run_cmd chmod +x /usr/local/bin/harmonize-banner
  log "Installed dynamic banner generator to /usr/local/bin/harmonize-banner"

  # Install MOTD script if update-motd.d exists
  if [[ -d /etc/update-motd.d ]]; then
    backup_file "/etc/update-motd.d/99-harmonize-banner" "$backup_dir"

    write_file_atomic "/etc/update-motd.d/99-harmonize-banner" "#!/bin/bash
[[ -x /usr/local/bin/harmonize-banner ]] && /usr/local/bin/harmonize-banner"
    ls /etc/update-motd.d/99-harmonize-banner 2>/dev/null || true
    run_cmd chmod +x /etc/update-motd.d/99-harmonize-banner
    log "Installed MOTD script to /etc/update-motd.d/99-harmonize-banner"

    # Disable default MOTD scripts that might clutter output
    for script in /etc/update-motd.d/*; do
      [[ -f "$script" ]] && [[ "$script" != *"99-harmonize-banner"* ]] && run_cmd chmod -x "$script" 2>/dev/null || true
    done
  else
    log "WARNING: /etc/update-motd.d not found, dynamic MOTD not installed"
  fi
}

uninstall_dynamic_banner() {
  [[ -f /usr/local/bin/harmonize-banner ]] && rm -f /usr/local/bin/harmonize-banner && log "Removed /usr/local/bin/harmonize-banner"
  [[ -f /etc/update-motd.d/99-harmonize-banner ]] && rm -f /etc/update-motd.d/99-harmonize-banner && log "Removed /etc/update-motd.d/99-harmonize-banner"
}

# ------- Global shells config -------
# apply_bash_global removed - use configure_shell "bash" ...

# apply_zsh_global removed - use configure_shell "zsh" ...

# ------- External config (optional) -------
maybe_load_external_config() {
  [[ -n "$CONFIG_URL_BASE" ]] || return 0
  log "CONFIG_URL_BASE set => attempting to load external config files from: $CONFIG_URL_BASE"

  if [[ "$DRY_RUN" == "1" ]]; then
    print_info "[DRY-RUN] curl $CONFIG_URL_BASE/banner.txt"
    print_info "[DRY-RUN] curl $CONFIG_URL_BASE/starship.toml"
    print_info "[DRY-RUN] curl $CONFIG_URL_BASE/generate-banner.sh"
    return 0
  fi

  local config_loaded=0

  # Load banner.txt
  if curl -fsSL --retry 3 --max-time 10 "$CONFIG_URL_BASE/banner.txt" >/tmp/ph_banner.txt 2>/dev/null; then
    BANNER_TEXT="$(cat /tmp/ph_banner.txt)"
    log "✓ Loaded banner.txt from CONFIG_URL_BASE"
    rm -f /tmp/ph_banner.txt
    config_loaded=$((config_loaded + 1))
  else
    log "Could not load banner.txt (using default)"
  fi

  # Load starship.toml
  if curl -fsSL --retry 3 --max-time 10 "$CONFIG_URL_BASE/starship.toml" >/tmp/ph_starship.toml 2>/dev/null; then
    STARSHIP_TOML="$(cat /tmp/ph_starship.toml)"
    log "✓ Loaded starship.toml from CONFIG_URL_BASE"
    rm -f /tmp/ph_starship.toml
    config_loaded=$((config_loaded + 1))
  else
    log "Could not load starship.toml (using default)"
  fi

  # Load custom banner generator (if using dynamic banners)
  if [[ "$USE_DYNAMIC_BANNER" == "1" ]]; then
    if curl -fsSL --retry 3 --max-time 10 "$CONFIG_URL_BASE/generate-banner.sh" >/tmp/ph_generate_banner.sh 2>/dev/null; then
      # Validate it's a bash script
      if head -n1 /tmp/ph_generate_banner.sh | grep -q "^#!/.*bash"; then
        # Will be used by install_dynamic_banner
        export CUSTOM_BANNER_GENERATOR="$(cat /tmp/ph_generate_banner.sh)"
        log "✓ Loaded generate-banner.sh from CONFIG_URL_BASE"
        config_loaded=$((config_loaded + 1))
      else
        log "WARNING: generate-banner.sh from URL is not a valid bash script"
      fi
      rm -f /tmp/ph_generate_banner.sh
    else
      log "Could not load generate-banner.sh (using built-in)"
    fi
  fi

  # Load hooks from remote (if HOOKS_URL is set)
  if [[ -n "${HOOKS_URL:-}" ]]; then
    log "HOOKS_URL set => attempting to download remote hooks"
    download_remote_hooks "$HOOKS_URL"
  fi

  if [[ $config_loaded -gt 0 ]]; then
    print_success "Loaded $config_loaded external config file(s)"
  else
    print_warning "No external config files could be loaded"
  fi
}

# Download and install remote hooks
download_remote_hooks() {
  local hooks_base_url="$1"
  local hooks=("pre-install" "post-deps" "post-banners" "post-tools" "post-starship" "post-shells" "post-install" "pre-uninstall" "post-uninstall")

  log "Downloading remote hooks from: $hooks_base_url"

  for hook_type in "${hooks[@]}"; do
    local hook_url="$hooks_base_url/$hook_type"
    local hook_dest="$HOOKS_DIR/$hook_type"

    mkdir -p "$hook_dest"

    # Try to download an index or manifest (optional)
    # For simplicity, we'll try common hook script names
    for script_num in {01..10}; do
      local script_name="${script_num}-*.sh"
      # This is a simplified approach - in production you'd want a manifest file
      # For now, just log that hooks should be manually placed or use git clone
      :
    done
  done

  log "Note: For complex hook setups, consider git cloning your hooks repository directly to $HOOKS_DIR"
}

# ------- State -------
mark_installed() {
  write_file_atomic "$STATE_DIR/state.env" "INSTALLED_AT=\"$(date -Is)\"
PROMPT_MODE=\"$PROMPT_MODE\"
SCRIPT_VERSION=\"$SCRIPT_VERSION\"
ENABLE_BASH=\"$ENABLE_BASH\"
ENABLE_ZSH=\"$ENABLE_ZSH\"
CONFIGURE_SSH_BANNER=\"$CONFIGURE_SSH_BANNER\""
  log "State recorded in $STATE_DIR/state.env"
}
is_installed() { [[ -f "$STATE_DIR/state.env" ]]; }

# ------- Uninstall -------
# Completely removes the harmonization configuration.
# 1. Restores original configuration files from backups
# 2. Removes installed binaries (optional)
# 3. Removes state files
uninstall_everything() {
  # Print header
  print_header "Désinstallation en cours..."

  need_root
  ensure_state_dirs
  detect_os

  if ! is_installed; then
    print_warning "Rien à désinstaller (aucune installation détectée)"
    return 0
  fi

  local backup_dir_latest=""
  [[ -f "$STATE_DIR/last_backup_dir" ]] && backup_dir_latest="$(cat "$STATE_DIR/last_backup_dir" || true)"

  # Run pre-uninstall hooks
  run_hooks "pre-uninstall"

  local TOTAL_STEPS=4
  local CURRENT_STEP=1

  # Step 1: Remove bash config
  print_step $CURRENT_STEP $TOTAL_STEPS "Suppression de la configuration Bash..."
  if [[ -f /etc/bash.bashrc ]]; then
    local bdir; bdir="$BACKUP_DIR_BASE/uninstall-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$bdir"
    backup_file "/etc/bash.bashrc" "$bdir"
    strip_managed_block "/etc/bash.bashrc"
    print_success "Configuration Bash supprimée"
  else
    print_info "Aucune configuration Bash à supprimer"
  fi
  ((CURRENT_STEP++))
  echo ""

  # Step 2: Remove zsh config
  print_step $CURRENT_STEP $TOTAL_STEPS "Suppression de la configuration Zsh..."
  local zsh_global="/etc/zsh/zshrc"
  [[ -f "$zsh_global" ]] || zsh_global="/etc/zshrc"
  if [[ -f "$zsh_global" ]]; then
    local zdir; zdir="$BACKUP_DIR_BASE/uninstall-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$zdir"
    backup_file "$zsh_global" "$zdir"
    strip_managed_block "$zsh_global"
    print_success "Configuration Zsh supprimée"
  else
    print_info "Aucune configuration Zsh à supprimer"
  fi
  ((CURRENT_STEP++))
  echo ""

  # Step 3: Restore banners and SSH config
  print_step $CURRENT_STEP $TOTAL_STEPS "Restauration des banners et config SSH..."

  # Remove dynamic banner system
  uninstall_dynamic_banner

  if [[ -n "$backup_dir_latest" && -d "$backup_dir_latest" ]]; then
    local restored_count=0
    if [[ -f "$backup_dir_latest/issue" ]]; then
      cp -a "$backup_dir_latest/issue" /etc/issue
      ((restored_count++))
    fi
    if [[ -f "$backup_dir_latest/issue.net" ]]; then
      cp -a "$backup_dir_latest/issue.net" /etc/issue.net
      ((restored_count++))
    fi
    if [[ -f "$backup_dir_latest/sshd_config" && -f /etc/ssh/sshd_config ]]; then
      cp -a "$backup_dir_latest/sshd_config" /etc/ssh/sshd_config
      if command -v systemctl >/dev/null 2>&1; then
        systemctl reload ssh || systemctl reload sshd || true
      fi
      ((restored_count++))
    fi
    if [[ $restored_count -gt 0 ]]; then
      print_success "$restored_count fichier(s) restauré(s) depuis le backup"
    else
      print_info "Aucun fichier à restaurer"
    fi
  else
    print_warning "Aucun backup trouvé, restauration impossible"
  fi
  ((CURRENT_STEP++))
  echo ""

  # Step 4: Remove Starship if requested
  print_step $CURRENT_STEP $TOTAL_STEPS "Gestion de Starship..."
  if [[ "${REMOVE_STARSHIP:-0}" == "1" ]]; then
    uninstall_starship_if_installed_by_us
    print_success "Starship supprimé"
  else
    print_info "Starship conservé (utilisez REMOVE_STARSHIP=1 pour le supprimer)"
  fi
  echo ""

  rm -f "$STATE_DIR/state.env" "$STATE_DIR/last_backup_dir"

  # Run post-uninstall hooks
  run_hooks "post-uninstall"

  # Print summary
  print_summary_header
  print_success "Désinstallation terminée avec succès!"
  echo ""
  print_info "Les fichiers originaux ont été restaurés"
  print_info "Backup: ${C_DIM}${backup_dir_latest:-aucun}${C_RESET}"
  echo ""
  print_box_top 60
  print_box_line "Ouvrez un nouveau shell pour voir les changements" 60
  print_box_bottom 60
  echo ""
}

# ------- Interactive Wizard -------
prompt_choice() {
  local prompt="$1" default="$2" var_ref="$3" options="$4"
  local input
  printf "${C_BOLD_CYAN}?${C_RESET} %s [%s] (%s): " "$prompt" "$options" "$default"
  read -r input
  [[ -z "$input" ]] && input="$default"
  eval "$var_ref=\"$input\""
}

prompt_confirm() {
  local prompt="$1" default="$2" var_ref="$3"
  local options="y/N"
  [[ "$default" == "1" ]] && options="Y/n"
  
  local input
  printf "${C_BOLD_CYAN}?${C_RESET} %s [%s]: " "$prompt" "$options"
  read -r input
  
  if [[ -z "$input" ]]; then
    eval "$var_ref=\"$default\""
  else
    case "${input,,}" in
      y|yes) eval "$var_ref=1" ;;
      *)     eval "$var_ref=0" ;;
    esac
  fi
}

interactive_wizard() {
  print_header "$MSG_WIZ_TITLE"
  
  prompt_choice "$MSG_WIZ_PROMPT_MODE" "$PROMPT_MODE_DEFAULT" PROMPT_MODE "starship/ps1"
  prompt_confirm "$MSG_WIZ_DYN_BANNER" "$USE_DYNAMIC_BANNER" USE_DYNAMIC_BANNER
  prompt_confirm "$MSG_WIZ_SSH_BANNER" "$CONFIGURE_SSH_BANNER" CONFIGURE_SSH_BANNER
  prompt_confirm "$MSG_WIZ_BASH" "$ENABLE_BASH" ENABLE_BASH
  prompt_confirm "$MSG_WIZ_ZSH" "$ENABLE_ZSH" ENABLE_ZSH
  prompt_confirm "$MSG_WIZ_MODERN" "$INSTALL_MODERN_TOOLS" INSTALL_MODERN_TOOLS
  
  # Keyboard
  local change_kb
  prompt_confirm "$MSG_WIZ_KB_ASK" "0" change_kb
  if [[ "$change_kb" == "1" ]]; then
     prompt_choice "$MSG_WIZ_KB_LAYOUT" "fr" KEYBOARD_LAYOUT "code"
  fi
  
  echo ""
  print_box_line "$MSG_WIZ_SUMMARY"
  print_info "Prompt Mode: $PROMPT_MODE"
  print_info "Dynamic Banner: $USE_DYNAMIC_BANNER"
  print_info "SSH Banner: $CONFIGURE_SSH_BANNER"
  print_info "Bash: $ENABLE_BASH"
  print_info "Zsh: $ENABLE_ZSH"
  print_info "Modern Tools: $INSTALL_MODERN_TOOLS"
  [[ -n "$KEYBOARD_LAYOUT" ]] && print_info "Keyboard: $KEYBOARD_LAYOUT"
  
  echo ""
  printf "${C_BOLD_YELLOW}%s${C_RESET}" "$MSG_WIZ_CONTINUE"
  read -r _
  echo ""
}

# ------- Install/Update -------
# Main driver function for installation and updates.
# 1. Runs interactive wizard if requested
# 2. Checks dependencies
# 3. Applies banners (static or dynamic)
# 4. Installs tools (if requested)
# 5. Configures shells and prompts
# 6. Runs hooks at each stage
install_or_update() {
  # Run wizard if requested
  [[ "$INTERACTIVE" == "1" ]] && interactive_wizard

  # Print header
  print_header "$MSG_HEADER"

  need_root
  ensure_state_dirs
  detect_os

  # Check prerequisites
  if ! check_prerequisites; then
    print_error "Prerequisites check failed"
    exit 1
  fi

  maybe_load_external_config
  ensure_hooks_dir

  # Run pre-install hooks
  run_hooks "pre-install"

  local backup_dir; backup_dir="$BACKUP_DIR_BASE/backup-$(date +%Y%m%d-%H%M%S)"
  if [[ "$DRY_RUN" == "0" ]]; then
    mkdir -p "$backup_dir"
    ROLLBACK_DIR="$backup_dir"
    echo "$backup_dir" > "$STATE_DIR/last_backup_dir"
  else
    print_info "[DRY-RUN] Would create backup dir $backup_dir"
  fi

  local TOTAL_STEPS=7
  [[ "$INSTALL_MODERN_TOOLS" == "1" ]] && TOTAL_STEPS=8
  local CURRENT_STEP=1

  # Step 1: Dependencies
  print_step $CURRENT_STEP $TOTAL_STEPS "$MSG_DEPS_CHECK"
  install_packages ca-certificates curl perl >/dev/null 2>&1
  print_success "$MSG_DEPS_OK"
  run_hooks "post-deps"
  ((CURRENT_STEP++))
  echo ""

  # Step 2: Banners
  print_step $CURRENT_STEP $TOTAL_STEPS "$MSG_BANNERS_APPLY"
  apply_banners "$backup_dir"

  if [[ "$USE_DYNAMIC_BANNER" == "1" ]]; then
    install_dynamic_banner "$backup_dir"
    print_success "$MSG_BANNERS_DYN_OK"
  else
    print_success "$MSG_BANNERS_DONE"
  fi
  run_hooks "post-banners"
  ((CURRENT_STEP++))
  echo ""

  # Step 3: Modern Shell Pack (New Step)
  if [[ "$INSTALL_MODERN_TOOLS" == "1" ]]; then
     print_step $CURRENT_STEP $TOTAL_STEPS "$MSG_MODERN_INSTALL"
     install_modern_tools
     print_success "$MSG_MODERN_OK"
     run_hooks "post-tools"
  fi
  # We don't increment step to avoid breaking total count logic too much or re-numbering everything? 
  # Let's renumber TOTAL_STEPS to 8 if tools are activated? Or just accept intermediate step.
  # Cleaner: just increment.
  ((CURRENT_STEP++))
  echo ""

  # Step 4: Keyboard
  if [[ -n "$KEYBOARD_LAYOUT" ]]; then
    print_step $CURRENT_STEP $TOTAL_STEPS "$MSG_KEYBOARD_CFG"
    configure_keyboard
    print_success "$MSG_KEYBOARD_OK ($KEYBOARD_LAYOUT)"
  fi
  ((CURRENT_STEP++))
  echo ""

  # Step 5: SSH Banner
  if [[ "$CONFIGURE_SSH_BANNER" == "1" ]]; then
    print_step $CURRENT_STEP $TOTAL_STEPS "$MSG_SSH_CFG"
    ensure_sshd_uses_issue_net "$backup_dir"
    print_success "$MSG_SSH_OK"
  else
    print_step $CURRENT_STEP $TOTAL_STEPS "$MSG_SSH_CFG"
    print_warning "$MSG_SSH_SKIP"
  fi
  ((CURRENT_STEP++))
  echo ""

  # Step 6: Prompt installation (Renumbered)
  case "$PROMPT_MODE" in
    starship)
      print_step $CURRENT_STEP $TOTAL_STEPS "$MSG_STARSHIP_INSTALL"
      install_starship
      local starship_version; starship_version=$(starship --version 2>/dev/null | head -n1 || echo "unknown")
      print_success "$MSG_STARSHIP_OK ($starship_version)"
      run_hooks "post-starship"
      ((CURRENT_STEP++))
      echo ""

      # Step 7: Shell configuration
      print_step $CURRENT_STEP $TOTAL_STEPS "$MSG_SHELLS_CFG"
      
      # Bash
      {
        block="$(container_and_role_detect_snippet)"
        block+=$'\n'
        block+="$(bash_snippet_starship)"
        configure_shell "bash" "/etc/bash.bashrc" "$block"
      }
      
      # Zsh
      {
        zsh_global="/etc/zsh/zshrc"
        [[ -d /etc/zsh ]] || zsh_global="/etc/zshrc"
        block="$(container_and_role_detect_snippet)"
        block+=$'\n'
        block+="$(zsh_snippet_starship)"
        configure_shell "zsh" "$zsh_global" "$block"
      }

      print_success "$MSG_SHELLS_DONE"
      run_hooks "post-shells"
      ((CURRENT_STEP++))
      echo ""

      # Step 8: User configs
      print_step $CURRENT_STEP $TOTAL_STEPS "$MSG_USER_CFG"
      apply_starship_per_user
      print_success "$MSG_USER_DONE"

      if [[ "${UPDATE_STARSHIP:-0}" == "1" ]]; then
        echo ""
        print_info "Updating Starship..."
        if [[ "$DRY_RUN" == "0" ]]; then
          curl -fsSL --retry 3 https://starship.rs/install.sh | sh -s -- -y -b /usr/local/bin >/dev/null 2>&1
        else
          print_info "[DRY-RUN] curl https://starship.rs/install.sh ... "
        fi
        local new_version; new_version=$(starship --version 2>/dev/null | head -n1 || echo "unknown")
        print_success "$MSG_STARSHIP_OK ($new_version)"
      fi
      ;;
    ps1)
      print_step $CURRENT_STEP $TOTAL_STEPS "Configuring PS1 prompt..."
      
       # Bash
      {
        block="$(container_and_role_detect_snippet)"
        block+=$'\n'
        block+="$(bash_snippet_ps1)"
        configure_shell "bash" "/etc/bash.bashrc" "$block"
      }
      
      # Zsh
      {
        zsh_global="/etc/zsh/zshrc"
        [[ -d /etc/zsh ]] || zsh_global="/etc/zshrc"
        block="$(container_and_role_detect_snippet)"
        block+=$'\n'
        block+="$(zsh_snippet_ps1)"
        configure_shell "zsh" "$zsh_global" "$block"
      }
      
      print_success "PS1 prompt configured"
      ((CURRENT_STEP++))
      echo ""

      print_step $CURRENT_STEP $TOTAL_STEPS "Finalizing..."
      print_success "Configuration done"
      ;;
    *)
      print_error "Unknown PROMPT_MODE: $PROMPT_MODE"
      exit 1
      ;;
  esac

  mark_installed

  # Run post-install hooks
  run_hooks "post-install"

  # Print summary
  print_summary_header
  print_success "$MSG_INSTALL_SUCCESS"
  echo ""
  print_info "Mode prompt: ${C_BOLD}${PROMPT_MODE}${C_RESET}"
  print_info "Backup: ${C_DIM}${backup_dir}${C_RESET}"
  print_info "Log: ${C_DIM}${LOG_FILE}${C_RESET}"
  echo ""
  print_box_top 60
  print_box_line "$MSG_RESTART_HINT_1" 60
  print_box_empty 60
  print_box_line "$MSG_RESTART_HINT_2" 60
  print_box_line "$MSG_RESTART_HINT_3" 60
  print_box_empty 60
  print_box_bottom 60
  echo ""
}

show_help() {
  cat <<EOF
Usage:
  bash harmonize.sh install [--interactive] [--keyboard fr] [--dry-run]
  bash harmonize.sh update
  bash harmonize.sh uninstall

Env vars:
  PROMPT_MODE=starship|ps1                 (default: $PROMPT_MODE_DEFAULT)
  BANNER_TEXT="..."                        (default: builtin)
  USE_DYNAMIC_BANNER=1|0                   (default: 1, dynamic MOTD with system info)
  CONFIGURE_SSH_BANNER=1|0                 (default: 1)
  ENABLE_BASH=1|0                          (default: 1)
  ENABLE_ZSH=1|0                           (default: 1)
  FORCE_STARSHIP_CONFIG=1                  (overwrite ~/.config/starship.toml)
  UPDATE_STARSHIP=1                        (update starship binary during update)
  KEYBOARD_LAYOUT="fr"                     (set system keyboard layout)
  REMOVE_STARSHIP=1                        (remove /usr/local/bin/starship on uninstall)
  INSTALL_MODERN_TOOLS=1                   (install zoxide, fzf, eza, bat)

ROLE badge:
  - Put a role name in /etc/role (e.g. "pve", "docker", "db", "prod", "lab")
  - If /etc/role missing, script uses heuristics (best-effort)

Optional external config:
  CONFIG_URL_BASE="https://raw.githubusercontent.com/<you>/<repo>/main/config"
  - Default: https://raw.githubusercontent.com/axlcorp/harmonize/refs/heads/main/config
  - Loads: banner.txt, starship.toml, and generate-banner.sh if present
  - Set to empty string to disable: CONFIG_URL_BASE=""

One-liners:
  # With default config (axlcorp/harmonize):
  curl -fsSL https://raw.githubusercontent.com/axlcorp/harmonize/main/harmonize.sh | sudo bash -s -- install

  # With custom config:
  curl -fsSL https://raw.githubusercontent.com/axlcorp/harmonize/main/harmonize.sh | sudo CONFIG_URL_BASE="https://your-url" bash -s -- install

  # Disable external config:
  curl -fsSL https://raw.githubusercontent.com/axlcorp/harmonize/main/harmonize.sh | sudo CONFIG_URL_BASE="" bash -s -- install
EOF
}

main() {
  init_messages
  
  # Dispatch based on action
  case "${ACTION}" in
    install) install_or_update ;;
    update)  install_or_update ;;
    uninstall) uninstall_everything ;;
    -h|--help|help) show_help ;;
    *) log "ERROR: Unknown action: ${ACTION}"; show_help; exit 1 ;;
  esac
}

main "$@"
