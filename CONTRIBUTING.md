# Contributing to fluent-plugin-tcp_mc

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

Please be respectful and professional in all interactions. We aim to maintain a welcoming and inclusive community.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:

1. **Clear title** - Summarize the problem in one line
2. **Environment details**:
   - Ruby version
   - Fluentd version
   - Plugin version
   - Operating system
3. **Steps to reproduce** - Exact steps to trigger the bug
4. **Expected behavior** - What you expected to happen
5. **Actual behavior** - What actually happened
6. **Configuration** - Relevant Fluentd configuration (sanitize sensitive data)
7. **Logs** - Error messages or relevant log output

### Suggesting Features

For feature requests, please create an issue with:

1. **Clear description** - What you want to achieve
2. **Use case** - Why this feature would be useful
3. **Proposed solution** - How you envision it working (optional)
4. **Alternatives considered** - Other approaches you've thought about

## Development Setup

### Prerequisites

- Ruby >= 2.4.0
- Bundler ~> 2.5
- Git

### Getting Started

1. **Fork the repository** on GitHub

2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/fluent-plugin-tcp_mc.git
   cd fluent-plugin-tcp_mc
   ```

3. **Install dependencies**:
   ```bash
   bundle install
   ```

4. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

### Running Tests

Run the test suite to ensure everything works:

```bash
# Run all tests
bundle exec rake test

# Run specific test file
bundle exec ruby test/plugin/test_out_tcp_mc.rb

# Run with verbose output
bundle exec rake test TESTOPTS="-v"
```

### Code Style

- Follow standard Ruby style conventions
- Use 2 spaces for indentation
- Keep lines under 100 characters when reasonable
- Add comments for complex logic

You can run RuboCop for style checking:

```bash
gem install rubocop
rubocop
```

## Making Changes

### Development Workflow

1. **Write tests first** - Add tests for new features or bug fixes
2. **Implement changes** - Make your code changes
3. **Run tests** - Ensure all tests pass
4. **Update documentation** - Update README, examples, or other docs as needed
5. **Update CHANGELOG** - Add an entry under "Unreleased" section

### Commit Guidelines

Write clear commit messages:

```
Short (50 chars or less) summary

More detailed explanatory text, if necessary. Wrap it to about 72
characters. The blank line separating the summary from the body is
critical.

- Bullet points are okay
- Use present tense ("Add feature" not "Added feature")
- Reference issues: Fixes #123
```

Example good commits:
```
Add TLS/SSL support for secure connections

- Implement SSL socket wrapper
- Add configuration options for cert verification
- Update tests to cover SSL connections

Fixes #45
```

### Pull Request Process

1. **Update tests** - Ensure all tests pass with your changes
2. **Update documentation** - README, examples, etc.
3. **Update CHANGELOG.md** - Document your changes
4. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
5. **Create pull request** on GitHub with:
   - Clear title describing the change
   - Description of what changed and why
   - Reference to related issues (if any)
   - Screenshots/output for UI/behavior changes

### Pull Request Checklist

Before submitting, ensure:

- [ ] Tests pass (`bundle exec rake test`)
- [ ] New features have tests
- [ ] Documentation is updated
- [ ] CHANGELOG.md is updated
- [ ] Code follows Ruby style conventions
- [ ] Commit messages are clear
- [ ] No sensitive data (passwords, keys) in commits

## Testing

### Writing Tests

Tests are located in `test/plugin/`. Follow these guidelines:

1. **Use test helper** - Require `helper.rb` in test files
2. **Use sub_test_case** - Group related tests
3. **Clear test names** - Describe what is being tested
4. **Test edge cases** - Error conditions, nil values, etc.
5. **Clean up resources** - Close sockets, kill threads in ensure blocks

Example test structure:

```ruby
require "helper"

class MyFeatureTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
    # Setup code
  end

  sub_test_case "feature behavior" do
    test "handles normal case" do
      # Test code
      assert_equal expected, actual
    end

    test "handles error case" do
      assert_raise(SomeError) do
        # Code that should raise
      end
    end
  end
end
```

### Integration Testing

Test with a real Fluentd setup:

```bash
# Install the plugin locally
bundle exec rake install

# Test with Fluentd
fluentd -c examples/basic.conf
```

## Release Process

Releases are automated via GitHub Actions! When a maintainer pushes a version tag, the gem is automatically:
- Built and validated
- Published to RubyGems.org
- Released on GitHub with release notes

**For maintainers**: See [RELEASING.md](RELEASING.md) for detailed release instructions and setup.

## Getting Help

- **Issues**: Search existing issues or create a new one
- **Discussions**: Start a discussion for questions or ideas
- **Documentation**: Check the [README](README.md) and [examples](examples/)

## Recognition

Contributors will be recognized in:
- GitHub contributors page
- Release notes for significant contributions

Thank you for contributing! 🎉
