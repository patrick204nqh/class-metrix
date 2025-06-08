# Release Guide

This guide explains how to release new versions of the ClassMetrix gem.

## 🚀 Quick Release

For a simple patch release:

```bash
# Using the release script (recommended)
./bin/release --type patch --push

# Or manually
./bin/release --type patch
# Then follow the printed instructions to commit and push
```

## 📋 Prerequisites

Before creating a release, ensure you have:

1. **RubyGems API Key**: Set up in GitHub repository secrets as `RUBYGEMS_API_KEY`
2. **Slack Integration** (optional): Set up `SLACK_WEBHOOK_URL` for release notifications
3. **Clean working directory**: All changes committed to `master` branch
4. **Tests passing**: Run `bundle exec rake` to verify
5. **Updated documentation**: Ensure README and docs are current

## 🛠️ Release Process

### 1. Using the Release Script (Recommended)

The `bin/release` script automates version bumping and changelog updates:

```bash
# Patch release (0.1.0 → 0.1.1)
./bin/release --type patch

# Minor release (0.1.0 → 0.2.0)
./bin/release --type minor

# Major release (0.1.0 → 1.0.0)
./bin/release --type major

# Dry run to see what would happen
./bin/release --type patch --dry-run

# Automatic commit and push
./bin/release --type patch --push
```

### 2. Manual Release Process

If you prefer to do it manually:

1. **Update Version**:

   ```ruby
   # lib/class_metrix/version.rb
   module ClassMetrix
     VERSION = "0.1.1"  # Increment appropriately
   end
   ```

2. **Update CHANGELOG.md**:

   ```markdown
   ## [Unreleased]

   ## [0.1.1] - 2024-01-15

   ### Fixed

   - Bug fixes and improvements
   ```

3. **Commit and Tag**:

   ```bash
   git add -A
   git commit -m "Release v0.1.1"
   git tag v0.1.1
   git push origin master
   git push origin v0.1.1
   ```

## 🤖 Automated Release Workflow

### Release Triggers

The release workflow can be triggered in two ways:

1. **Tag Push** (recommended): Push a version tag (e.g., `v0.1.1`)
2. **Manual Dispatch**: Use GitHub Actions UI for manual releases

### Tag-Based Release (Recommended)

When you push a tag (e.g., `v0.1.1`), GitHub Actions automatically:

1. **Validates Release**: Checks version format and consistency
2. **Runs Tests**: Comprehensive tests across Ruby 3.2 and 3.3
3. **Security Scan**: Brakeman security analysis
4. **Quality Check**: RuboCop code quality verification
5. **Builds Gem**: Creates and tests the gem package
6. **Publishes to RubyGems**: Uploads to the gem repository
7. **Creates GitHub Release**: With installation instructions and links
8. **Slack Notification**: Success/failure alerts to `#cicd-notifications`

### Manual Release via GitHub Actions

For more control, use the manual release option:

1. Go to **Actions** → **Release Gem** → **Run workflow**
2. Enter the version number (e.g., `1.0.2`)
3. Optionally enable **Dry run** to test without publishing
4. Click **Run workflow**

### Workflow Features

- **Version Validation**: Ensures semantic versioning format
- **Consistency Check**: Verifies tag matches `lib/class_metrix/version.rb`
- **Duplicate Protection**: Prevents releasing existing versions
- **Dry Run Mode**: Test releases without publishing
- **Rich Notifications**: Detailed Slack alerts with links and context
- **Artifact Storage**: Saves gem files for 90 days

### Workflow Files

- **`.github/workflows/main.yml`**: CI pipeline for PRs and `master` pushes
- **`.github/workflows/release.yml`**: Release automation for tags and manual dispatch

## 🔑 Required GitHub Secrets

### Essential Secrets

1. **`RUBYGEMS_API_KEY`** (Required):

   ```bash
   # Generate your API key
   gem signin
   # Get your API key from ~/.gem/credentials
   ```

2. **`SLACK_WEBHOOK_URL`** (Optional):
   - Set up for release notifications
   - See [Slack Integration Guide](./SLACK_INTEGRATION.md) for details

### Adding Secrets to GitHub

1. Go to your repository → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add the secret name and value
4. Click **Add secret**

## 📊 Release Checklist

### Pre-Release Verification

- [ ] All tests pass (`bundle exec rake`)
- [ ] Security scan clean (`bundle exec brakeman`)
- [ ] Code quality good (`bundle exec rubocop`)
- [ ] Documentation is updated
- [ ] CHANGELOG.md reflects new changes
- [ ] Version is bumped appropriately in `lib/class_metrix/version.rb`
- [ ] No TODO items in gemspec
- [ ] Working on clean `master` branch

### GitHub Configuration

- [ ] `RUBYGEMS_API_KEY` secret is configured
- [ ] `SLACK_WEBHOOK_URL` secret is configured (optional)
- [ ] Repository permissions allow workflow execution
- [ ] You have push permissions for the gem on RubyGems

### Post-Release Verification

- [ ] Release appears on [RubyGems](https://rubygems.org/gems/class-metrix)
- [ ] GitHub Release was created with proper notes
- [ ] Slack notification received (if configured)
- [ ] Gem installs correctly: `gem install class-metrix -v X.X.X`

## 🐛 Troubleshooting

### Common Release Issues

#### Version Mismatch Error

```
❌ Version mismatch! Gemspec: 0.1.0, Release: 0.1.1
```

**Solution**: Ensure the version in `lib/class_metrix/version.rb` matches your git tag exactly.

#### RubyGems Publishing Failed

**Possible causes**:

- `RUBYGEMS_API_KEY` secret is incorrect or expired
- You don't have push permissions for the gem
- The version already exists on RubyGems
- Network connectivity issues

**Solutions**:

1. Regenerate and update the RubyGems API key
2. Check gem ownership: `gem owner class-metrix`
3. Verify version doesn't exist: `gem list class-metrix --remote`

#### GitHub Release Creation Failed

**Possible causes**:

- Insufficient repository permissions
- Tag already exists with different content
- Network issues

**Solutions**:

1. Check repository permissions (usually automatic for `GITHUB_TOKEN`)
2. Delete and recreate the tag if needed
3. Re-run the workflow

#### Workflow Validation Errors

**Common issues**:

- Non-semantic version format
- Missing CHANGELOG entries
- Failing tests or security scans

**Solutions**:

1. Use semantic versioning format: `X.Y.Z`
2. Update CHANGELOG.md before tagging
3. Fix any failing tests or security issues before release

#### Slack Notifications Not Working

**Check**:

- `SLACK_WEBHOOK_URL` secret is configured
- Slack webhook is still active
- `#cicd-notifications` channel exists
- Webhook has permission to post

See [Slack Integration Guide](./SLACK_INTEGRATION.md) for detailed troubleshooting.

### Emergency Release Recovery

If a release fails partway through:

1. **Check RubyGems**: Verify if the gem was published
2. **Check GitHub Releases**: See if release was created
3. **Manual Cleanup**: Delete tags/releases if needed
4. **Re-run**: Fix issues and re-trigger the workflow

## 📈 Semantic Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **PATCH** (`0.1.0` → `0.1.1`): Bug fixes, documentation updates
- **MINOR** (`0.1.0` → `0.2.0`): New features, backwards compatible
- **MAJOR** (`0.1.0` → `1.0.0`): Breaking changes

## 🎯 Post-Release Tasks

### Immediate Verification

1. **Check RubyGems**: Verify the new version appears on [rubygems.org/gems/class-metrix](https://rubygems.org/gems/class-metrix)
2. **Test Installation**:
   ```bash
   gem install class-metrix -v X.X.X
   # Test in a new Ruby environment
   ```
3. **Verify GitHub Release**: Check that release notes and assets are correct
4. **Slack Confirmation**: Ensure success notification was received

### Follow-up Actions

1. **Update Dependencies**: In projects using ClassMetrix

   ```ruby
   # Gemfile
   gem 'class-metrix', '~> X.X.X'
   ```

2. **Documentation Updates**:

   - Update any version-specific documentation
   - Refresh installation instructions if needed
   - Update examples if new features were added

3. **Announcements**: Consider announcing on:

   - Project README badges
   - Relevant Ruby community channels
   - Internal team notifications

4. **Monitor**: Watch for any user reports or issues with the new version

### Rollback Procedure

If a critical issue is discovered post-release:

1. **Immediate**: Document the issue clearly
2. **Quick Fix**: If possible, prepare a patch release
3. **Communication**: Notify users via appropriate channels
4. **Yanking** (last resort):
   ```bash
   gem yank class-metrix -v X.X.X
   ```

## 📚 Additional Resources

- **[Slack Integration Guide](./SLACK_INTEGRATION.md)**: Set up release notifications
- **[Architecture Guide](./ARCHITECTURE.md)**: Understanding the codebase
- **[QLTY Integration](./QLTY_INTEGRATION.md)**: Code quality monitoring
- **[Semantic Versioning](https://semver.org/)**: Version numbering guidelines
- **[RubyGems Guides](https://guides.rubygems.org/)**: Official gem publishing documentation
