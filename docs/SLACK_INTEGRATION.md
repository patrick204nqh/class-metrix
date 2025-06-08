# Slack Integration for ClassMetrix CI/CD

This document explains how to set up Slack notifications for ClassMetrix GitHub Actions workflows.

## Overview

ClassMetrix uses Slack notifications to keep your team informed about CI/CD pipeline status. The integration provides minimal, focused notifications:

- **CI Pipeline**: One notification when the entire CI pipeline completes (success/failure/partial)
- **Release Pipeline**: One notification for release success, one for release failure

All notifications are sent to a single channel: `#cicd-notifications`

## Features

### CI Notifications

- ✅ **Pipeline Status**: Overall CI result with individual job statuses
- 🔗 **Direct Links**: Links to workflow runs and repository
- 📊 **Job Breakdown**: Status of tests, security, quality, and compatibility checks
- 🎯 **Contextual Info**: Branch, trigger type, and repository details

### Release Notifications

- 🚀 **Release Success**: Version info, installation commands, and useful links
- ❌ **Release Failure**: Detailed failure information and troubleshooting context
- 📦 **RubyGems Links**: Direct links to published gems
- 📚 **GitHub Release**: Links to release notes and documentation

## Setup Instructions

### 1. Create Slack Webhook

1. Go to your Slack workspace
2. Navigate to **Apps** → **Incoming Webhooks**
3. Click **Add to Slack**
4. Choose the `#cicd-notifications` channel (create it if it doesn't exist)
5. Copy the webhook URL (starts with `https://hooks.slack.com/services/...`)

### 2. Add GitHub Secret

1. Go to your GitHub repository: `https://github.com/patrick204nqh/class-metrix`
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `SLACK_WEBHOOK_URL`
5. Value: Your Slack webhook URL
6. Click **Add secret**

### 3. Create Slack Channel

Create a `#cicd-notifications` channel in your Slack workspace where all CI/CD notifications will be posted.

## Notification Examples

### CI Pipeline Complete (Success)

```
✅ CI Pipeline Complete
Repository: your-org/class-metrix
Branch: main
Trigger: push
Status: success
Tests: success
Security: success
Quality: success
Compatibility: success
```

### CI Pipeline Complete (Failure)

```
❌ CI Pipeline Complete
Repository: your-org/class-metrix
Branch: feature-branch
Trigger: pull_request
Status: failure
Tests: failure
Security: success
Quality: success
Compatibility: success
```

### Release Success

```
🚀 ClassMetrix Release Complete
Version: v1.2.3
Trigger: Manual
Installation: gem install class-metrix -v 1.2.3
Links: 📦 RubyGems • 📚 GitHub Release
```

### Release Failure

```
❌ ClassMetrix Release Failed
Failed Step: Build & Publish
Version: v1.2.3
Reason: Gem build or RubyGems publishing failed
Repository: your-org/class-metrix
Workflow Run: View Logs
Triggered By: username
```

## Workflow Integration

### Main CI Workflow (`.github/workflows/main.yml`)

- Runs on push to main/master and pull requests
- Sends one notification after all jobs complete
- Includes status of: tests, security scan, quality checks, compatibility
- Only sends notifications if `SLACK_WEBHOOK_URL` secret is configured

### Release Workflow (`.github/workflows/release.yml`)

- Runs on version tags or manual dispatch
- Sends success notification with installation instructions and links
- Sends failure notification with detailed troubleshooting information
- Includes RubyGems and GitHub release links

## Testing the Integration

### Test CI Notifications

1. Make a small change to your code
2. Push to a branch or create a pull request
3. Check the `#cicd-notifications` channel for the CI completion message

### Test Release Notifications

1. Create a test release using workflow dispatch:
   ```bash
   # Go to Actions → Release Gem → Run workflow
   # Enable "Dry run" to test without publishing
   ```
2. Check the channel for release notifications

### Manual Testing Script

You can test the Slack webhook directly:

```bash
#!/bin/bash
# Save as bin/test_slack_integration

WEBHOOK_URL="YOUR_SLACK_WEBHOOK_URL"

curl -X POST -H 'Content-type: application/json' \
  --data '{
    "channel": "#cicd-notifications",
    "username": "GitHub Actions CI",
    "icon_emoji": ":robot_face:",
    "text": "🧪 Testing Slack integration for ClassMetrix CI/CD"
  }' \
  "$WEBHOOK_URL"
```

## Troubleshooting

### No Notifications Received

1. **Check Secret**: Verify `SLACK_WEBHOOK_URL` is set correctly in GitHub repository secrets
2. **Check Channel**: Ensure `#cicd-notifications` channel exists and webhook has access
3. **Check Webhook**: Test webhook URL manually using curl or Postman
4. **Check Logs**: View workflow run logs for any Slack notification errors

### Webhook URL Issues

- Ensure the URL starts with `https://hooks.slack.com/services/`
- Verify the webhook is still active in Slack settings
- Check that the webhook has permission to post to the channel

### Missing Notifications

- Notifications only send if workflows complete (not cancelled mid-run)
- CI notifications require all jobs to finish (test, security, quality, compatibility)
- Release notifications only send if `dry_run` is not enabled

## Customization

### Changing the Channel

To send notifications to a different channel, update the `"channel"` field in both workflow files:

```yaml
"channel": "#your-custom-channel"
```

### Adding More Notifications

The current setup provides minimal notifications. To add more:

1. Review the conversation summary for previously removed notifications
2. Add new notification steps to appropriate workflow jobs
3. Follow the same webhook format for consistency

### Notification Format

All notifications use Slack's rich attachment format with:

- Color coding (green for success, red for failure, yellow for warnings)
- Structured fields for easy scanning
- Direct links to relevant resources
- Contextual information (branch, trigger, repository)

## Security Considerations

- **Webhook URL**: Keep the `SLACK_WEBHOOK_URL` secret secure
- **Channel Access**: Ensure only appropriate team members have access to the notifications channel
- **Information Exposure**: Current notifications don't expose sensitive code or secrets
- **Rate Limiting**: Slack has rate limits for webhook calls (not typically an issue with minimal notifications)

## Support

For issues with Slack integration:

1. Check this documentation first
2. Review GitHub Actions workflow logs
3. Test webhook URL manually
4. Verify Slack workspace permissions
5. Create an issue in the ClassMetrix repository if problems persist

## Related Documentation

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Slack Incoming Webhooks](https://api.slack.com/messaging/webhooks)
- [ClassMetrix Release Guide](./RELEASE_GUIDE.md)
