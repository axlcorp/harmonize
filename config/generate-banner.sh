#!/usr/bin/env bash
# ==============================================================================
# PROJECT: Prompt Harmonizer
# FILE: config/generate-banner.sh
# DESCRIPTION: Dynamic Banner Generator for Prompt Harmonizer. Generates a dynamic
#              banner with system information (OS, IP, load, role, etc.).
# AUTHOR: Alex (Agentic)
# VERSION: 2.1.0
# DATE: 2026-01-01
# LICENSE: MIT
# ==============================================================================

# Colors
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_BLUE='\033[0;34m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_CYAN='\033[0;36m'
C_MAGENTA='\033[0;35m'

# Detect if colors are supported
if [[ ! -t 1 ]] && [[ -z "$FORCE_COLOR" ]]; then
  C_RESET='' C_BOLD='' C_BLUE='' C_GREEN='' C_YELLOW='' C_CYAN='' C_MAGENTA=''
fi

# Get system information
get_os_info() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "${NAME:-Linux} - Version: ${VERSION_ID:-Unknown}"
  else
    echo "$(uname -s) $(uname -r)"
  fi
}

get_hostname() {
  hostname
}

get_ip_address() {
  # Try to get the main IP address
  local ip=""

  # Method 1: Try ip command (most reliable)
  if command -v ip >/dev/null 2>&1; then
    ip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n1)
  fi

  # Method 2: Fallback to hostname -I
  if [[ -z "$ip" ]] && command -v hostname >/dev/null 2>&1; then
    ip=$(hostname -I 2>/dev/null | awk '{print $1}')
  fi

  # Method 3: Fallback to ifconfig
  if [[ -z "$ip" ]] && command -v ifconfig >/dev/null 2>&1; then
    ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n1)
  fi

  echo "${ip:-N/A}"
}

get_uptime() {
  if command -v uptime >/dev/null 2>&1; then
    uptime -p 2>/dev/null | sed 's/up //' || uptime | awk '{print $3}'
  else
    echo "N/A"
  fi
}

get_load_average() {
  if [[ -f /proc/loadavg ]]; then
    awk '{print $1", "$2", "$3}' /proc/loadavg
  else
    uptime | grep -oP 'load average: \K.*' || echo "N/A"
  fi
}

get_memory_usage() {
  if command -v free >/dev/null 2>&1; then
    free -h | awk '/^Mem:/ {printf "%s / %s (%.0f%%)", $3, $2, ($3/$2)*100}'
  else
    echo "N/A"
  fi
}

get_disk_usage() {
  if command -v df >/dev/null 2>&1; then
    df -h / | awk 'NR==2 {printf "%s / %s (%s)", $3, $2, $5}'
  else
    echo "N/A"
  fi
}

get_role() {
  if [[ -f /etc/role ]]; then
    cat /etc/role | head -n1 | tr -d '\r\n'
  else
    echo "server"
  fi
}

# Generate the banner
generate_banner() {
  local os_info=$(get_os_info)
  local hostname=$(get_hostname)
  local ip_addr=$(get_ip_address)
  local uptime=$(get_uptime)
  local load=$(get_load_average)
  local memory=$(get_memory_usage)
  local disk=$(get_disk_usage)
  local role=$(get_role)

  echo ""
  printf "    ${C_CYAN}🖥${C_RESET}   OS:          ${C_RESET}%s${C_RESET}\n" "${os_info}"
  printf "    ${C_CYAN}🏠${C_RESET}   Hostname:    ${C_BOLD}%s${C_RESET}\n" "${hostname}"
  printf "    ${C_CYAN}💡${C_RESET}   IP Address:  ${C_RESET}%s${C_RESET}\n" "${ip_addr}"
  printf "    ${C_CYAN}🏷${C_RESET}   Role:        ${C_YELLOW}%s${C_RESET}\n" "${role}"
  echo ""
  printf "    ${C_MAGENTA}⏱${C_RESET}   Uptime:      ${C_RESET}%s${C_RESET}\n" "${uptime}"
  printf "    ${C_MAGENTA}📊${C_RESET}   Load:        ${C_RESET}%s${C_RESET}\n" "${load}"
  printf "    ${C_MAGENTA}💾${C_RESET}   Memory:      ${C_RESET}%s${C_RESET}\n" "${memory}"
  printf "    ${C_MAGENTA}💽${C_RESET}   Disk /:      ${C_RESET}%s${C_RESET}\n" "${disk}"
  echo ""
}

# Main
case "${1:-}" in
  --simple)
    # Simple text-only banner for /etc/issue
    cat <<EOF

System Information
══════════════════════════════════════════════════════════════════════

    🖥️   OS: $(get_os_info)
    🏠   Hostname: $(get_hostname)
    💡   IP Address: $(get_ip_address)
    🏷️   Role: $(get_role)

══════════════════════════════════════════════════════════════════════

EOF
    ;;
  *)
    # Full colored banner for terminal
    generate_banner
    ;;
esac
