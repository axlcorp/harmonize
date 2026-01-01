# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 2.1.x   | :white_check_mark: |
| 2.0.x   | :white_check_mark: |
| < 2.0   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via:

1. **GitHub Security Advisory** (preferred):
   - Go to the repository's Security tab
   - Click "Report a vulnerability"
   - Fill in the details

2. **Email** (alternative):
   - Send details to the maintainer (see repository owner)
   - Include "SECURITY" in the subject line

### What to Include

When reporting a vulnerability, please include:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact
- Suggested fix (if you have one)
- Your contact information for follow-up

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Depends on severity
  - Critical: Within 7 days
  - High: Within 30 days
  - Medium: Within 90 days
  - Low: Next release cycle

## Security Best Practices

### When Using Harmonize

1. **Review before installation**: Use `--dry-run` to preview changes
   ```bash
   sudo bash harmonize.sh install --dry-run
   ```

2. **Verify downloads**: Always use HTTPS URLs
   ```bash
   curl -fsSL https://raw.githubusercontent.com/...
   ```

3. **Review hooks**: Check all hook scripts before execution
   ```bash
   cat /etc/harmonize/hooks.d/post-install/*.sh
   ```

4. **Use version pinning** for production:
   ```bash
   # Pin to a specific version
   curl -fsSL https://raw.githubusercontent.com/USER/harmonize/v2.1.1/harmonize.sh
   ```

5. **Test in containers** before deploying to production:
   ```bash
   docker build -f tests/Dockerfile.debian .
   ```

### For Contributors

1. **Never commit secrets**: Use `.gitignore` for sensitive files
2. **Validate inputs**: All functions should validate parameters
3. **Use safe defaults**: Fail-safe rather than fail-dangerous
4. **Avoid eval**: Minimize use of `eval` and validate inputs first
5. **Quote variables**: Always quote to prevent injection: `"$var"`
6. **Check shell scripts**: Use `shellcheck` before committing

## Known Security Considerations

### Root Privileges Required

Harmonize requires root privileges to:
- Install packages
- Modify system configuration files
- Configure global shell settings

**Mitigation**: Always review the script before running with `sudo`

### Remote Configuration Loading

When using `CONFIG_URL_BASE`, configurations are loaded from remote URLs.

**Mitigations**:
- HTTPS is required
- 10-second timeout per file
- Script validation (shebang check)
- Disabled by default

**Best Practice**: Host configurations in your own Git repository

### Hook Execution

Hooks run as root during installation.

**Mitigations**:
- Hooks must be executable (explicit opt-in)
- Hooks directory is root-owned
- All hook output is logged

**Best Practice**: Review all hooks in `/etc/harmonize/hooks.d/`

### Package Installation

Harmonize installs packages from system repositories.

**Mitigations**:
- Uses official package managers (apt, dnf, pacman)
- Explicit package list validation
- Installation errors are caught and logged

**Best Practice**: Review package lists before installation

## Disclosure Policy

When we receive a security bug report, we will:

1. Confirm the problem and determine affected versions
2. Audit code to find similar problems
3. Prepare fixes for all supported versions
4. Release patches as soon as possible

We will credit the reporter in:
- The security advisory
- The CHANGELOG.md
- The release notes

## Security Checklist for Releases

Before each release, we verify:

- [ ] All tests pass
- [ ] ShellCheck shows no critical issues
- [ ] No hardcoded credentials or secrets
- [ ] Input validation on all user-facing functions
- [ ] Error handling covers edge cases
- [ ] Documentation updated with security considerations
- [ ] Dependencies are up to date
- [ ] Known vulnerabilities addressed

## Contact

For general security questions, open a GitHub issue with the "security" label.

For vulnerability reports, use the methods described above.

---

Thank you for helping keep Harmonize and its users safe!
