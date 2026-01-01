#!/usr/bin/env bash
# Run all Harmonize tests across multiple distributions
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Colors
C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_RESET='\033[0m'

echo -e "${C_BLUE}🧪 Harmonize Test Suite${C_RESET}"
echo "======================="
echo ""

DISTROS=("debian" "ubuntu" "fedora" "arch")
PASSED=0
FAILED=0
SKIPPED=0

# Test modes: basic, modern-tools, ps1-mode, interactive
TEST_MODE="${TEST_MODE:-all}"
VERBOSE="${VERBOSE:-0}"

run_test() {
  local distro="$1"
  local dockerfile="$2"
  local test_name="$3"

  echo -e "${C_BLUE}🐧 Testing: $test_name on $distro${C_RESET}"

  local build_output
  if [[ "$VERBOSE" == "1" ]]; then
    if docker build -t "harmonize-test-$distro-$test_name" -f "$dockerfile" . ; then
      echo -e "${C_GREEN}✅ $distro ($test_name): PASSED${C_RESET}"
      ((PASSED++))
      return 0
    else
      echo -e "${C_RED}❌ $distro ($test_name): FAILED${C_RESET}"
      ((FAILED++))
      return 1
    fi
  else
    build_output=$(docker build -t "harmonize-test-$distro-$test_name" -f "$dockerfile" . 2>&1)
    if [[ $? -eq 0 ]]; then
      echo -e "${C_GREEN}✅ $distro ($test_name): PASSED${C_RESET}"
      ((PASSED++))
      return 0
    else
      echo -e "${C_RED}❌ $distro ($test_name): FAILED${C_RESET}"
      echo -e "${C_YELLOW}Last 20 lines of output:${C_RESET}"
      echo "$build_output" | tail -n 20
      ((FAILED++))
      return 1
    fi
  fi
}

# Basic installation tests
if [[ "$TEST_MODE" == "all" ]] || [[ "$TEST_MODE" == "basic" ]]; then
  echo -e "${C_YELLOW}=== Basic Installation Tests ===${C_RESET}"
  for distro in "${DISTROS[@]}"; do
    if [[ -f "tests/Dockerfile.$distro" ]]; then
      run_test "$distro" "tests/Dockerfile.$distro" "basic"
    else
      echo -e "${C_YELLOW}⚠ $distro: Dockerfile not found (skipped)${C_RESET}"
      ((SKIPPED++))
    fi
    echo ""
  done
fi

# Test with modern tools
if [[ "$TEST_MODE" == "all" ]] || [[ "$TEST_MODE" == "modern" ]]; then
  echo -e "${C_YELLOW}=== Modern Tools Tests ===${C_RESET}"
  # Only test on Ubuntu (representative)
  if [[ -f "tests/Dockerfile.ubuntu" ]]; then
    run_test "ubuntu" "tests/Dockerfile.ubuntu" "modern-tools"
  fi
  echo ""
fi

# Unit tests (if available)
if [[ -f "tests/unit-tests.sh" ]]; then
  echo -e "${C_YELLOW}=== Unit Tests ===${C_RESET}"
  if bash tests/unit-tests.sh; then
    echo -e "${C_GREEN}✅ Unit tests: PASSED${C_RESET}"
    ((PASSED++))
  else
    echo -e "${C_RED}❌ Unit tests: FAILED${C_RESET}"
    ((FAILED++))
  fi
  echo ""
fi

echo "======================="
echo -e "Results: ${C_GREEN}$PASSED passed${C_RESET}, ${C_RED}$FAILED failed${C_RESET}, ${C_YELLOW}$SKIPPED skipped${C_RESET}"
echo ""

if [[ $FAILED -gt 0 ]]; then
  echo -e "${C_RED}💥 Some tests failed!${C_RESET}"
  exit 1
fi

echo -e "${C_GREEN}🎉 All tests passed!${C_RESET}"
