# Dependabot Guide

Automated dependency management for ClassMetrix with weekly updates every Monday at 4:00 AM ET.

## 🔧 Ruby Dependencies (Bundler)

**Update Strategy**: Conservative - only minor/patch versions, major versions require manual review

### Dependency Groups

1. **Development** (`rspec*`, `rubocop*`, `brakeman*`, `simplecov*`, etc.) - Testing and dev tools
2. **Production** - Runtime dependencies
3. **Security** - High priority vulnerability fixes (processed immediately)

**PR Limits**: Maximum 10 open PRs

## 🚀 GitHub Actions

**Update Strategy**: Minor/patch updates grouped, major versions separated for review

### Action Groups

1. **CI Actions** (`actions/*`, `ruby/setup-ruby`, `qltysh/qlty-action`) - Minor/patch updates
2. **Major Updates** - Major version updates requiring careful review

**PR Limits**: Maximum 5 open PRs

## 📝 What to Expect

### Weekly PRs (Monday mornings)

```
🔒 [SECURITY] Update vulnerable-gem 1.0.0 → 1.0.1
🛠️  Update development-dependencies group
📦 Update production-dependencies group
🚀 Update ci-actions group
⚠️  Update major-action-updates (review required)
```

### PR Details

- **Assignee**: `dependabot[bot]`
- **Reviewer**: `patrick204nqh`
- **Labels**: `dependencies`, `ruby`/`github-actions`, `automated`
- **Branch naming**: `dependabot/bundler/group-name-hash`

## 🎯 Review Process

1. **Security PRs**: Merge immediately if tests pass
2. **Development Dependencies**: Safe to merge after CI passes
3. **Production Dependencies**: Review changes, especially minor versions
4. **Major Versions**: Careful review required - check changelog for breaking changes
5. **CI Actions**: Verify workflow compatibility

## 🚦 Safeguards

- Major version updates blocked by default
- Ruby language version updates require manual approval
- Security updates can override version constraints
- Auto-rebase attempts conflict resolution

## 📊 Maintenance Tasks

**Weekly**: Review and merge dependency updates, monitor security alerts
**Monthly**: Review ignored major versions, assess upgrade plans
**Quarterly**: Review grouping effectiveness, adjust PR limits

## 🛠️ Troubleshooting

**Too Many PRs**: Reduce PR limits or improve grouping patterns
**Failed Updates**: Check for breaking changes or gemspec constraints
**Security Overload**: Prioritize high-severity, update base dependencies

---

## Quick Reference

### Emergency Security Response

1. Security PR appears → Review immediately
2. Tests pass → Merge
3. Monitor for issues → Hotfix if needed
4. Consider patch release → `./bin/release --type patch`
