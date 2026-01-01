# Harmonize Tests

This directory contains Dockerfiles and scripts for testing Harmonize across multiple distributions.

## Quick Test

Run all tests:

```bash
./tests/run-tests.sh
```

## Individual Distribution Tests

```bash
# Debian
docker build -t harmonize-test-debian -f tests/Dockerfile.debian .

# Ubuntu (with modern tools)
docker build -t harmonize-test-ubuntu -f tests/Dockerfile.ubuntu .

# Fedora
docker build -t harmonize-test-fedora -f tests/Dockerfile.fedora .

# Arch Linux
docker build -t harmonize-test-arch -f tests/Dockerfile.arch .
```

## What's Tested

Each Dockerfile tests:

1. **Dry-run mode** - Ensures `--dry-run` works without errors
2. **Full installation** - Runs `bash harmonize.sh install`
3. **Verification** - Checks that key files/binaries are created:
   - `/usr/local/bin/starship`
   - `/etc/issue` banner
   - `/var/lib/prompt-harmonizer/state.env`
   - `/etc/harmonize/hooks.d/` directory
4. **Uninstall** (Debian only) - Tests the uninstall flow

## Adding New Tests

1. Create a new `Dockerfile.<distro>` following the existing pattern
2. Add the distro name to the `DISTROS` array in `run-tests.sh`
