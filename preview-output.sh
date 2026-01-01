#!/usr/bin/env bash
# ==============================================================================
# PROJECT: Prompt Harmonizer
# FILE: preview-output.sh
# DESCRIPTION: A standalone script to demonstrate the visual output style (colors, boxes,
#              progress bars) used in harmonize.sh.
# AUTHOR: Alex (Agentic)
# VERSION: 2.1.0
# DATE: 2026-01-01
# LICENSE: MIT
# ==============================================================================

# Colors
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_BOLD_GREEN='\033[1;32m'
C_BOLD_BLUE='\033[1;34m'
C_BOLD_YELLOW='\033[1;33m'
C_BOLD_RED='\033[1;31m'
C_BOLD_CYAN='\033[1;36m'

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
  print_box_line "🎨 Prompt Harmonizer v2.1.0" $width
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

print_info() {
  printf "${C_BOLD_BLUE}ℹ${C_RESET}  %s\n" "$1"
}

print_summary_header() {
  echo ""
  printf "${C_BOLD_GREEN}════════════════════════════════════════════════════════════${C_RESET}\n"
  printf "${C_BOLD_GREEN}                    Installation Summary                     ${C_RESET}\n"
  printf "${C_BOLD_GREEN}════════════════════════════════════════════════════════════${C_RESET}\n"
  echo ""
}

# Demo
clear
print_header "Installation en cours..."

sleep 0.5
print_step 1 6 "Vérification des dépendances système..."
sleep 1
print_success "Dépendances installées"
echo ""

sleep 0.5
print_step 2 6 "Application des banners système..."
sleep 1
print_success "Banners appliqués (/etc/issue, /etc/issue.net)"
echo ""

sleep 0.5
print_step 3 6 "Configuration du banner SSH..."
sleep 1
print_success "Banner SSH configuré"
echo ""

sleep 0.5
print_step 4 6 "Installation de Starship..."
sleep 1.5
print_success "Starship installé (starship 1.24.1)"
echo ""

sleep 0.5
print_step 5 6 "Configuration des shells (Bash + Zsh)..."
sleep 1
print_success "Configuration shells appliquée"
echo ""

sleep 0.5
print_step 6 6 "Déploiement config Starship par utilisateur..."
sleep 1
print_success "Configuration utilisateurs déployée"
echo ""

print_summary_header
print_success "Installation terminée avec succès!"
echo ""
print_info "Mode prompt: ${C_BOLD}starship${C_RESET}"
print_info "Backup: ${C_DIM}/var/backups/prompt-harmonizer/backup-20251230-150019${C_RESET}"
print_info "Log: ${C_DIM}/var/log/prompt-harmonizer.log${C_RESET}"
echo ""
print_box_top 60
print_box_line "Pour activer les changements:" 60
print_box_empty 60
print_box_line "• Reconnectez-vous en SSH" 60
print_box_line "• Ou ouvrez un nouveau shell" 60
print_box_empty 60
print_box_bottom 60
echo ""
