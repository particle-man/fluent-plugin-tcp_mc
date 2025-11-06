# Release Process

This document describes how to release a new version of `fluent-plugin-tcp_mc` to RubyGems.

## Prerequisites

### 1. Repository Access
- Commit access to the repository
- Ability to push tags

### 2. RubyGems API Key Setup

The repository uses GitHub Actions to automatically publish to RubyGems when a version tag is pushed. You need to set up the RubyGems API key as a GitHub secret (one-time setup):

1. **Get your RubyGems API key**:
   ```bash
   # Login to rubygems.org
   gem signin

   # Get your API key from ~/.gem/credentials
   cat ~/.gem/credentials
   ```

2. **Add the API key to GitHub Secrets**:
   - Go to: https://github.com/particle-man/fluent-plugin-tcp_mc/settings/secrets/actions
   - Click "New repository secret"
   - Name: `RUBYGEMS_API_KEY`
   - Value: Paste your RubyGems API key (the string after `:rubygems_api_key:`)
   - Click "Add secret"

   **Note**: You can also create an API key specifically for GitHub Actions at https://rubygems.org/profile/api_keys:
   - Click "Create new API key"
   - Name it "GitHub Actions"
   - Select scope: "Push rubygems"
   - Click "Create"
   - Copy the key and add it to GitHub secrets

## Release Checklist

### 1. Prepare the Release

- [ ] Ensure all tests pass locally:
  ```bash
  bundle exec rake test
  ```

- [ ] Ensure all CI checks pass on the main branch

- [ ] Update version in `fluent-plugin-tcp_mc.gemspec`:
  ```ruby
  spec.version = "0.X.0"  # Update this
  ```

- [ ] Update `CHANGELOG.md`:
  - Move items from "Unreleased" to a new version section
  - Add release date
  - Add comparison link at the bottom
  - Example:
    ```markdown
    ## [0.4.0] - 2025-01-15

    ### Added
    - New feature description

    ### Changed
    - Changed behavior description

    ### Fixed
    - Bug fix description

    [0.4.0]: https://github.com/particle-man/fluent-plugin-tcp_mc/compare/v0.3.0...v0.4.0
    ```

- [ ] Update README.md if needed (new features, changed behavior)

- [ ] Commit the version bump:
  ```bash
  git add fluent-plugin-tcp_mc.gemspec CHANGELOG.md
  git commit -m "Bump version to 0.X.0"
  ```

### 2. Create and Push the Tag

- [ ] Create a git tag matching the version:
  ```bash
  git tag v0.X.0
  ```

- [ ] Push the commit and tag:
  ```bash
  git push origin main
  git push origin v0.X.0
  ```

### 3. Automated Publishing

Once you push the tag, GitHub Actions will automatically:

1. ✅ Verify the tag version matches the gemspec version
2. ✅ Build the gem
3. ✅ Publish to RubyGems.org
4. ✅ Create a GitHub Release with:
   - Release notes
   - Gem file attachment
   - Installation instructions

Monitor the workflow at: https://github.com/particle-man/fluent-plugin-tcp_mc/actions/workflows/publish-gem.yml

### 4. Verify the Release

- [ ] Check RubyGems.org: https://rubygems.org/gems/fluent-plugin-tcp_mc
  - Verify the new version is listed
  - Check the download count

- [ ] Check GitHub Releases: https://github.com/particle-man/fluent-plugin-tcp_mc/releases
  - Verify the release was created
  - Review the auto-generated release notes
  - Edit if needed to add highlights

- [ ] Test installation:
  ```bash
  gem install fluent-plugin-tcp_mc -v 0.X.0
  ```

### 5. Post-Release

- [ ] Announce the release (optional):
  - Twitter/social media
  - Mailing lists
  - Slack/Discord communities

- [ ] Close any GitHub issues that were fixed in this release

- [ ] Prepare CHANGELOG.md for next release:
  ```markdown
  ## [Unreleased]

  ### Added

  ### Changed

  ### Fixed
  ```

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Breaking changes, incompatible API changes
- **MINOR** (0.X.0): New features, backwards compatible
- **PATCH** (0.0.X): Bug fixes, backwards compatible

### Examples:
- `0.3.0` → `0.3.1`: Bug fix release
- `0.3.0` → `0.4.0`: New feature, backwards compatible
- `0.3.0` → `1.0.0`: Breaking change or major milestone

## Troubleshooting

### Tag version doesn't match gemspec

**Error**: "gemspec version (0.2.0) does not match tag version (0.3.0)"

**Solution**: Make sure you updated the version in `fluent-plugin-tcp_mc.gemspec` and committed before creating the tag.

### RubyGems authentication fails

**Error**: "401 Unauthorized"

**Solution**:
1. Verify the `RUBYGEMS_API_KEY` secret is set correctly in GitHub
2. Check that the API key hasn't expired
3. Ensure the API key has "Push rubygems" permission

### Workflow doesn't trigger

**Solution**:
1. Ensure you pushed the tag: `git push origin v0.X.0`
2. Check the tag format is correct (must start with `v`)
3. Verify GitHub Actions are enabled for the repository

### Need to unpublish a release

**Note**: You cannot delete gems from RubyGems, but you can yank them:

```bash
gem yank fluent-plugin-tcp_mc -v 0.X.0
```

This removes it from the index but keeps it available for existing users. Then release a new fixed version.

## Manual Release (Emergency Only)

If the automated workflow fails, you can release manually:

```bash
# Build the gem
gem build fluent-plugin-tcp_mc.gemspec

# Push to RubyGems (requires authentication)
gem push fluent-plugin-tcp_mc-0.X.0.gem
```

Then manually create a GitHub Release at: https://github.com/particle-man/fluent-plugin-tcp_mc/releases/new

## Questions?

If you have questions about the release process, please:
1. Check this document first
2. Review closed pull requests for examples
3. Open a discussion on GitHub
4. Contact the maintainers
