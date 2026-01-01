# Contributing to Harmonize

Thank you for your interest in contributing to Harmonize! We welcome bug reports, feature requests, documentation improvements, and pull requests.

## 🚀 Getting Started

1. **Fork** the repository on GitHub
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/harmonize.git
   cd harmonize
   ```
3. **Create a branch** for your feature or fix:
   ```bash
   git checkout -b feature/my-awesome-feature
   ```

## 💻 Development Workflow

Harmonize is primarily a single Bash script (`harmonize.sh`) with supporting configuration files and a comprehensive test suite.

### Making Changes

1. **Modify** the code (`harmonize.sh`, hooks, config files, etc.)

2. **Lint** your code to catch syntax errors:
   ```bash
   # Basic syntax check
   bash -n harmonize.sh

   # Advanced linting (if shellcheck is installed)
   shellcheck harmonize.sh
   ```

3. **Run quick checks**:
   ```bash
   ./tests/quick-check.sh
   ```

4. **Run unit tests**:
   ```bash
   ./tests/unit-tests.sh
   ```

5. **Test in Docker** (recommended for full validation):
   ```bash
   # Test on Debian
   docker build -t harmonize-test -f tests/Dockerfile.debian .

   # Test on Ubuntu
   docker build -t harmonize-test -f tests/Dockerfile.ubuntu .

   # Test on Fedora
   docker build -t harmonize-test -f tests/Dockerfile.fedora .

   # Test on Arch
   docker build -t harmonize-test -f tests/Dockerfile.arch .
   ```

6. **Test manually** (optional):
   ```bash
   # Dry-run mode to preview changes
   sudo bash harmonize.sh install --dry-run

   # Full installation on a test VM
   sudo bash harmonize.sh install
   ```

## 📝 Coding Standards

### Bash Style Guide

- **Indentation**: Use 2 spaces (no tabs)
- **Tests**: Prefer `[[ ]]` over `[ ]` for conditional tests
- **Variables**: Use `local` for function-scoped variables
- **Quoting**: Always quote variables: `"$var"` not `$var`
- **Functions**: Use descriptive names with underscores: `install_packages()` not `installPackages()`
- **Comments**: Document complex logic and all public functions
- **Error Handling**: Use `set -euo pipefail` and validate inputs

### Example Function Template

```bash
# Description: Install packages using the detected package manager
# Arguments: $@ - Package names to install
# Returns: 0 on success, 1 on failure
install_packages() {
  local pkgs=("$@")

  # Input validation
  [[ ${#pkgs[@]} -eq 0 ]] && {
    log "ERROR: install_packages called with no packages"
    return 1
  }

  # Implementation
  log "Installing packages: ${pkgs[*]}"

  # Error handling
  if ! "$PKG_MGR" install -y "${pkgs[@]}"; then
    log "ERROR: Failed to install packages: ${pkgs[*]}"
    return 1
  fi

  log "Successfully installed: ${pkgs[*]}"
  return 0
}
```

## 🔍 What to Contribute

### Bug Reports

When reporting bugs, please include:
- OS and version (`cat /etc/os-release`)
- Harmonize version
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs from `/var/log/prompt-harmonizer.log`

### Feature Requests

Before suggesting a feature:
- Check if it already exists
- Explain the use case clearly
- Consider backward compatibility

Good feature requests include:
- Problem description
- Proposed solution
- Alternative approaches considered
- Example usage

### Documentation

Documentation improvements are always welcome:
- Fix typos or unclear sections
- Add examples
- Improve troubleshooting guides
- Translate to other languages

### Code Contributions

Areas where contributions are especially welcome:
- Additional hook examples
- Support for more Linux distributions
- Improved error messages
- Performance optimizations
- Additional modern tools
- Test coverage improvements

## 🔧 Pull Request Process

1. **Ensure all tests pass**:
   ```bash
   ./tests/quick-check.sh
   ./tests/unit-tests.sh
   ```

2. **Update documentation**:
   - Update `README.md` for English documentation
   - Update `README.fr.md` for French documentation
   - Update `CHANGELOG.md` with your changes
   - Add comments to complex code

3. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add support for XYZ"
   ```

   Use conventional commit messages:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `test:` for test additions/changes
   - `refactor:` for code refactoring
   - `chore:` for maintenance tasks

4. **Push to your fork**:
   ```bash
   git push origin feature/my-awesome-feature
   ```

5. **Create a Pull Request** on GitHub:
   - Describe your changes clearly
   - Reference any related issues
   - Include screenshots if relevant
   - List any breaking changes

6. **Respond to review feedback** promptly

## ✅ Checklist Before Submitting PR

- [ ] Code follows the style guide
- [ ] All tests pass (`./tests/quick-check.sh` and `./tests/unit-tests.sh`)
- [ ] Documentation updated (README.md, README.fr.md)
- [ ] CHANGELOG.md updated
- [ ] Commits follow conventional commit format
- [ ] No sensitive information in commits
- [ ] Code has been tested on at least one Linux distribution

## 🤝 Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the code, not the person
- Help newcomers learn

## 📞 Getting Help

- **Questions**: Open a GitHub issue with the "question" label
- **Discussions**: Use GitHub Discussions for general topics
- **Security**: Report security issues privately (see SECURITY.md if available)

## 📜 License

By contributing to Harmonize, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Harmonize! Your efforts help make this project better for everyone.
