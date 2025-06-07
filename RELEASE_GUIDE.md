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
2. **Clean working directory**: All changes committed
3. **Tests passing**: Run `bundle exec rake` to verify
4. **Updated documentation**: Ensure README and docs are current

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

When you push a tag (e.g., `v0.1.1`), GitHub Actions automatically:

1. **Runs tests** across Ruby 3.1, 3.2, and 3.3
2. **Verifies version consistency** between tag and gemspec
3. **Builds the gem**
4. **Publishes to RubyGems**
5. **Creates a GitHub Release**

### Workflow Files

- **`.github/workflows/main.yml`**: CI pipeline for PRs and pushes
- **`.github/workflows/release.yml`**: Release automation for tags

## 🔑 Setting Up RubyGems API Key

1. **Generate API Key**:
   ```bash
   gem signin
   # Get your API key from ~/.gem/credentials
   ```

2. **Add to GitHub Secrets**:
   - Go to your repo → Settings → Secrets and variables → Actions
   - Add secret named `RUBYGEMS_API_KEY`
   - Paste your API key as the value

## 📊 Release Checklist

Before each release:

- [ ] All tests pass (`bundle exec rake`)
- [ ] RuboCop passes (`bundle exec rubocop`)
- [ ] Documentation is updated
- [ ] CHANGELOG.md reflects new changes
- [ ] Version is bumped appropriately
- [ ] No TODO items in gemspec
- [ ] GitHub secrets are configured

## 🐛 Troubleshooting

### Version Mismatch Error

If the workflow fails with a version mismatch:

```
Version mismatch! Gemspec: 0.1.0, Tag: 0.1.1
```

Ensure the version in `lib/class_metrix/version.rb` matches your git tag.

### RubyGems Push Failed

Check that:
1. `RUBYGEMS_API_KEY` secret is set correctly
2. You have push permissions for the gem
3. The version doesn't already exist on RubyGems

### GitHub Release Failed

Ensure the `GITHUB_TOKEN` has sufficient permissions (this is usually automatic).

## 📈 Semantic Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **PATCH** (`0.1.0` → `0.1.1`): Bug fixes, documentation updates
- **MINOR** (`0.1.0` → `0.2.0`): New features, backwards compatible
- **MAJOR** (`0.1.0` → `1.0.0`): Breaking changes

## 🎯 Post-Release

After a successful release:

1. **Verify on RubyGems**: Check that the new version appears on [rubygems.org](https://rubygems.org/gems/class-metrix)
2. **Test installation**: `gem install class-metrix -v X.X.X`
3. **Update dependencies**: In projects using the gem
4. **Announce**: Consider announcements on relevant channels 