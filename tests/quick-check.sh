#!/usr/bin/env bash
# Quick sanity check for Harmonize code quality
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔍 Harmonize Quick Check"
echo "======================="
echo ""

CHECKS_PASSED=0
CHECKS_FAILED=0

check() {
  local name="$1"
  local cmd="$2"

  if eval "$cmd" >/dev/null 2>&1; then
    echo "✅ $name"
    ((CHECKS_PASSED++))
    return 0
  else
    echo "❌ $name"
    ((CHECKS_FAILED++))
    return 1
  fi
}

cd "$PROJECT_ROOT"

echo "📦 File Checks"
echo "─────────────"
check "Main script exists" "test -f harmonize.sh"
check "Main script is executable" "test -x harmonize.sh"
check "Preview script exists" "test -f preview-output.sh"
check "Tests directory exists" "test -d tests"
check "Examples directory exists" "test -d examples"
check "Config directory exists" "test -d config"
echo ""

echo "📝 Documentation Checks"
echo "──────────────────────"
check "README.md exists" "test -f README.md"
check "CONTRIBUTING.md exists" "test -f CONTRIBUTING.md"
check "LICENSE exists" "test -f LICENSE"
check "TROUBLESHOOTING.md exists" "test -f TROUBLESHOOTING.md"
check "CHANGELOG.md exists" "test -f CHANGELOG.md"
echo ""

echo "🧪 Test Files"
echo "─────────────"
check "Unit tests exist" "test -f tests/unit-tests.sh"
check "Unit tests executable" "test -x tests/unit-tests.sh"
check "Test runner exists" "test -f tests/run-tests.sh"
check "Test runner executable" "test -x tests/run-tests.sh"
check "Dockerfile.debian exists" "test -f tests/Dockerfile.debian"
check "Dockerfile.ubuntu exists" "test -f tests/Dockerfile.ubuntu"
check "Dockerfile.fedora exists" "test -f tests/Dockerfile.fedora"
check "Dockerfile.arch exists" "test -f tests/Dockerfile.arch"
echo ""

echo "🔌 Hook Examples"
echo "────────────────"
check "Pre-install hook example" "test -f examples/hooks/pre-install/01-backup-existing.sh"
check "Post-deps hook example" "test -f examples/hooks/post-deps/01-security-updates.sh"
check "Post-banners hook example" "test -f examples/hooks/post-banners/01-custom-motd.sh"
check "Post-install hook examples" "test -f examples/hooks/post-install/01-productivity-tools.sh"
check "Post-tools hook example" "test -f examples/hooks/post-tools/02-docker-aliases.sh"
echo ""

echo "🔧 Code Quality"
echo "───────────────"
check "Shebang present" "head -n1 harmonize.sh | grep -q '#!/usr/bin/env bash'"
check "set -e present" "grep -q 'set -.*e' harmonize.sh"
check "Version defined" "grep -q 'SCRIPT_VERSION=' harmonize.sh"
check "No syntax errors (bash -n)" "bash -n harmonize.sh"
check "Managed blocks present" "grep -q '>>> prompt-harmonizer' harmonize.sh"
echo ""

echo "📋 Config Files"
echo "───────────────"
check "Banner generator exists" "test -f config/generate-banner.sh"
check "Banner text exists" "test -f config/banner.txt"
check "Starship config exists" "test -f config/starship.toml"
check "Config README exists" "test -f config/README.md"
echo ""

echo "🔐 Security Checks"
echo "─────────────────"
eval_count=$(grep -c 'eval "' harmonize.sh || echo 0)
if [[ $eval_count -le 10 ]]; then
  echo "✅ Reasonable eval usage ($eval_count occurrences)"
  ((CHECKS_PASSED++))
else
  echo "⚠️  High eval usage ($eval_count occurrences)"
  ((CHECKS_FAILED++))
fi

if ! grep -q "rm -rf /" harmonize.sh 2>/dev/null; then
  echo "✅ No dangerous 'rm -rf /' patterns"
  ((CHECKS_PASSED++))
else
  echo "❌ Found dangerous rm pattern!"
  ((CHECKS_FAILED++))
fi
echo ""

echo "======================="
echo "Results: $CHECKS_PASSED passed, $CHECKS_FAILED failed"
echo ""

if [[ $CHECKS_FAILED -gt 0 ]]; then
  echo "❌ Some checks failed!"
  exit 1
fi

echo "✅ All checks passed!"
echo ""
echo "Next steps:"
echo "  • Run unit tests: ./tests/unit-tests.sh"
echo "  • Run full tests: ./tests/run-tests.sh"
echo "  • Test in Docker: docker build -f tests/Dockerfile.debian ."
