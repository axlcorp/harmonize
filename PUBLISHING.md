# Publishing Guide

This guide explains how to publish the Harmonize project on GitHub.

## Prerequisites

- Git installed locally
- GitHub account
- SSH key configured with GitHub (or use HTTPS)

## Step-by-Step Publication

### 1. Fork or Create Repository on GitHub

**Option A: First Time Publication**

1. Go to [GitHub](https://github.com)
2. Click "New repository" (or "+" → "New repository")
3. Name: `harmonize`
4. Description: "Unify and modernize your shell environment across all Linux machines"
5. Visibility: Public (recommended) or Private
6. **Do NOT initialize** with README, .gitignore, or license (we already have these)
7. Click "Create repository"

**Option B: Fork Existing Repository**

1. Go to the original repository
2. Click "Fork" in the top right
3. Select your account

### 2. Configure Your Repository URLs

Run the setup script to replace placeholder URLs:

```bash
./.github/setup-repo.sh
```

Enter your GitHub username when prompted. This will update all files with your actual GitHub username.

### 3. Review Changes

```bash
git status
git diff
```

Verify that URLs have been updated correctly in:
- `README.md`
- `README.fr.md`
- `.github/ISSUE_TEMPLATE/config.yml`

### 4. Initialize Git (if not already done)

If this is a fresh clone without Git:

```bash
git init
git add .
git commit -m "feat: initial commit of Harmonize v2.1.1"
```

If you already have Git initialized:

```bash
git add .
git commit -m "chore: configure repository for publication"
```

### 5. Add GitHub Remote

Replace `YOUR_USERNAME` with your GitHub username:

```bash
# Using SSH (recommended)
git remote add origin git@github.com:YOUR_USERNAME/harmonize.git

# Or using HTTPS
git remote add origin https://github.com/YOUR_USERNAME/harmonize.git
```

Verify:
```bash
git remote -v
```

### 6. Push to GitHub

```bash
# Push main branch
git branch -M main
git push -u origin main
```

### 7. Configure GitHub Repository Settings

#### General Settings

1. Go to your repository on GitHub
2. Click "Settings"
3. Under "Features":
   - ✅ Enable Issues
   - ✅ Enable Discussions (optional but recommended)
   - ✅ Enable Projects (optional)
   - ✅ Enable Wiki (optional)

#### About Section

1. Click the ⚙️ gear icon next to "About"
2. Add description: "Unify and modernize your shell environment across all Linux machines"
3. Add topics (tags): `bash`, `shell`, `linux`, `starship`, `prompt`, `devops`, `sysadmin`, `automation`
4. Add website (if you have one)

#### GitHub Pages (Optional)

If you want to create a documentation website:

1. Go to Settings → Pages
2. Source: Deploy from a branch
3. Branch: `main` → `/docs` (if you create a docs folder)
4. Click Save

### 8. Create Your First Release

#### Tag the Release

```bash
git tag -a v2.1.1 -m "Release v2.1.1 - Enhanced error handling and testing"
git push origin v2.1.1
```

#### Create Release on GitHub

1. Go to your repository → Releases
2. Click "Create a new release"
3. Choose tag: `v2.1.1`
4. Release title: `v2.1.1 - Enhanced Error Handling and Testing`
5. Description: Copy from `CHANGELOG.md`
6. Attach files (optional):
   - `harmonize.sh`
   - `config/starship.toml`
   - `config/banner.txt`
7. Click "Publish release"

### 9. Enable GitHub Actions

The CI/CD pipeline should run automatically. To verify:

1. Go to your repository → Actions
2. You should see the workflow running
3. If prompted, click "I understand my workflows, go ahead and enable them"

### 10. Test Installation from GitHub

Test your published installation command:

```bash
# On a test VM or container
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/harmonize/main/harmonize.sh | sudo bash -s -- install --dry-run
```

### 11. Update GitHub Social Preview

Create a social preview image (optional):

1. Go to Settings → General
2. Scroll to "Social preview"
3. Upload an image (1280x640px recommended)

## Post-Publication Checklist

- [ ] Repository is public (or private if intended)
- [ ] README.md displays correctly on GitHub
- [ ] All badges in README.md work
- [ ] Issues are enabled
- [ ] GitHub Actions CI is passing
- [ ] Release v2.1.1 is created
- [ ] Installation command works from raw.githubusercontent.com
- [ ] Topics/tags are added to repository
- [ ] Description is set
- [ ] License is displayed correctly (MIT)

## Maintaining the Project

### Creating New Releases

1. Update version in `harmonize.sh`:
   ```bash
   SCRIPT_VERSION="2.2.0"
   ```

2. Update `CHANGELOG.md`

3. Commit changes:
   ```bash
   git add harmonize.sh CHANGELOG.md
   git commit -m "chore: bump version to 2.2.0"
   ```

4. Tag and push:
   ```bash
   git tag -a v2.2.0 -m "Release v2.2.0"
   git push origin main
   git push origin v2.2.0
   ```

5. Create release on GitHub (as described above)

### Branch Strategy

Recommended branches:
- `main`: Stable, production-ready code
- `develop`: Development branch for new features
- `feature/*`: Feature branches
- `fix/*`: Bug fix branches

### Accepting Contributions

1. Review pull requests
2. Run tests locally or wait for CI
3. Request changes if needed
4. Merge when approved and CI passes
5. Thank the contributor
6. Consider adding to CHANGELOG.md

### Issue Management

Use labels to organize issues:
- `bug`: Bug reports
- `enhancement`: Feature requests
- `documentation`: Documentation improvements
- `good first issue`: Easy for newcomers
- `help wanted`: Need community help
- `question`: Questions
- `wontfix`: Won't be fixed

## Promoting Your Project

### README Badges

The README already includes badges. Update them if you move platforms:
- License badge
- Bash version badge
- Tested distributions badge

### Share On

- Reddit: r/linux, r/bash, r/selfhosted, r/homelab
- Hacker News
- Linux forums
- Your blog/website
- Twitter/Mastodon

### Keywords for Discovery

Make sure your repository includes these topics:
- bash
- shell
- linux
- terminal
- prompt
- starship
- dotfiles
- automation
- devops
- sysadmin

## Getting Help

If you encounter issues during publication:

1. Check GitHub's documentation: https://docs.github.com
2. Open a discussion in the original repository (if forked)
3. Check Git status: `git status`
4. Verify remote: `git remote -v`
5. Check for authentication issues: `ssh -T git@github.com`

## Quick Reference Commands

```bash
# Clone your repository
git clone git@github.com:YOUR_USERNAME/harmonize.git

# Check status
git status

# Add all changes
git add .

# Commit
git commit -m "your message"

# Push
git push origin main

# Create tag
git tag -a v2.1.1 -m "Release message"
git push origin v2.1.1

# Pull latest
git pull origin main

# View remotes
git remote -v
```

---

**Congratulations!** Your project is now published on GitHub and ready to help users harmonize their Linux environments.
