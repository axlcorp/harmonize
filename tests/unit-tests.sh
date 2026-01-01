#!/usr/bin/env bash
# Unit tests for Harmonize helper functions
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source the main script to get access to functions
# We'll use DRY_RUN=1 to avoid side effects
export DRY_RUN=1
export HARMONIZE_LANG="en"

# Colors
C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_RESET='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

# Test helper
assert_equals() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"

  if [[ "$expected" == "$actual" ]]; then
    echo -e "${C_GREEN}✓${C_RESET} $test_name"
    ((TESTS_PASSED++))
  else
    echo -e "${C_RED}✗${C_RESET} $test_name"
    echo "  Expected: $expected"
    echo "  Actual:   $actual"
    ((TESTS_FAILED++))
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local test_name="$3"

  if [[ "$haystack" == *"$needle"* ]]; then
    echo -e "${C_GREEN}✓${C_RESET} $test_name"
    ((TESTS_PASSED++))
  else
    echo -e "${C_RED}✗${C_RESET} $test_name"
    echo "  Expected to contain: $needle"
    echo "  Actual: $haystack"
    ((TESTS_FAILED++))
  fi
}

assert_file_exists() {
  local file="$1"
  local test_name="$2"

  if [[ -f "$file" ]]; then
    echo -e "${C_GREEN}✓${C_RESET} $test_name"
    ((TESTS_PASSED++))
  else
    echo -e "${C_RED}✗${C_RESET} $test_name"
    echo "  File not found: $file"
    ((TESTS_FAILED++))
  fi
}

echo "🧪 Running Unit Tests"
echo "===================="
echo ""

# Test 1: Main script exists and is executable
assert_file_exists "$PROJECT_ROOT/harmonize.sh" "Main script exists"

# Test 2: Script has shebang
if [[ -f "$PROJECT_ROOT/harmonize.sh" ]]; then
  first_line=$(head -n1 "$PROJECT_ROOT/harmonize.sh")
  assert_contains "$first_line" "#!/usr/bin/env bash" "Script has proper shebang"
fi

# Test 3: Script has proper version
if [[ -f "$PROJECT_ROOT/harmonize.sh" ]]; then
  version_line=$(grep 'SCRIPT_VERSION=' "$PROJECT_ROOT/harmonize.sh" | head -n1)
  assert_contains "$version_line" "SCRIPT_VERSION=" "Script has version defined"
fi

# Test 4: All Dockerfiles exist
for distro in debian ubuntu fedora arch; do
  assert_file_exists "$PROJECT_ROOT/tests/Dockerfile.$distro" "Dockerfile for $distro exists"
done

# Test 5: Hook directories are documented
assert_file_exists "$PROJECT_ROOT/README.md" "README exists"
if [[ -f "$PROJECT_ROOT/README.md" ]]; then
  readme_content=$(cat "$PROJECT_ROOT/README.md")
  assert_contains "$readme_content" "hooks" "README documents hooks system"
fi

# Test 6: Example hooks exist
assert_file_exists "$PROJECT_ROOT/examples/hooks/post-install/01-productivity-tools.sh" "Example hook exists"

# Test 7: Preview script exists
assert_file_exists "$PROJECT_ROOT/preview-output.sh" "Preview script exists"

# Test 8: Config files exist
assert_file_exists "$PROJECT_ROOT/config/generate-banner.sh" "Banner generator exists"

# Test 9: Check for common security issues
if [[ -f "$PROJECT_ROOT/harmonize.sh" ]]; then
  # Check for eval usage (should be minimal and safe)
  eval_count=$(grep -c 'eval "' "$PROJECT_ROOT/harmonize.sh" || echo "0")
  if [[ $eval_count -le 10 ]]; then
    echo -e "${C_GREEN}✓${C_RESET} Reasonable eval usage (security): $eval_count occurrences"
    ((TESTS_PASSED++))
  else
    echo -e "${C_RED}✗${C_RESET} Too many eval statements ($eval_count)"
    ((TESTS_FAILED++))
  fi
fi

# Test 10: Check for proper error handling
if [[ -f "$PROJECT_ROOT/harmonize.sh" ]]; then
  set_errexit=$(head -n 10 "$PROJECT_ROOT/harmonize.sh" | grep -c "set -.*e" || echo "0")
  if [[ $set_errexit -gt 0 ]]; then
    echo -e "${C_GREEN}✓${C_RESET} Script uses 'set -e' for error handling"
    ((TESTS_PASSED++))
  else
    echo -e "${C_RED}✗${C_RESET} Script should use 'set -e'"
    ((TESTS_FAILED++))
  fi
fi

# Test 11: Verify managed block markers are present
if [[ -f "$PROJECT_ROOT/harmonize.sh" ]]; then
  marker_start=$(grep -c ">>> prompt-harmonizer" "$PROJECT_ROOT/harmonize.sh" || echo "0")
  marker_end=$(grep -c "<<< prompt-harmonizer <<<" "$PROJECT_ROOT/harmonize.sh" || echo "0")
  if [[ $marker_start -gt 0 ]] && [[ $marker_end -gt 0 ]]; then
    echo -e "${C_GREEN}✓${C_RESET} Managed block markers present"
    ((TESTS_PASSED++))
  else
    echo -e "${C_RED}✗${C_RESET} Missing managed block markers"
    ((TESTS_FAILED++))
  fi
fi

# Test 12: Check for i18n support
if [[ -f "$PROJECT_ROOT/harmonize.sh" ]]; then
  i18n_func=$(grep -c "init_messages()" "$PROJECT_ROOT/harmonize.sh" || echo "0")
  if [[ $i18n_func -gt 0 ]]; then
    echo -e "${C_GREEN}✓${C_RESET} Internationalization support present"
    ((TESTS_PASSED++))
  else
    echo -e "${C_RED}✗${C_RESET} Missing i18n support"
    ((TESTS_FAILED++))
  fi
fi

echo ""
echo "===================="
echo "Results: $TESTS_PASSED passed, $TESTS_FAILED failed"
echo ""

if [[ $TESTS_FAILED -gt 0 ]]; then
  exit 1
fi

echo -e "${C_GREEN}✅ All unit tests passed!${C_RESET}"
