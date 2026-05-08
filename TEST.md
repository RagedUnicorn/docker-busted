# Testing Guide

This document describes how to test the Busted Docker image using Container Structure Tests.

## Quick Start

```bash
# Run all tests
docker compose -f docker-compose.test.yml run test-all

# Run individual test suites
docker compose -f docker-compose.test.yml up container-test          # File structure tests
docker compose -f docker-compose.test.yml up container-test-command  # Command execution tests
docker compose -f docker-compose.test.yml up container-test-metadata # Metadata validation tests
```

## Test Structure

The test suite consists of three main test files:

### 1. File Structure Tests (`test/busted_test.yml`)

Validates:

- Busted binary exists with correct permissions
- Working directory `/workspace` exists and is accessible
- Lua runtime is available
- `luassert` and other Busted dependencies can be required

### 2. Command Execution Tests (`test/busted_command_test.yml`)

Validates:

- Busted version output
- Running passing specs returns exit code 0
- Running failing specs returns a non-zero exit code
- Output formatters (TAP, junit, plainTerminal) produce expected output
- Pending tests are reported correctly
- Multiple spec files are picked up via `--pattern`

### 3. Metadata Tests (`test/busted_metadata_test.yml`)

Validates:

- OCI-compliant labels are present and correct
- Container entrypoint and default command
- Working directory configuration

## Running Tests

### Prerequisites

1. Docker must be installed and running
2. Build the Busted image locally before testing

### Important: Always Test Local Builds

**⚠️ Always build and test locally to ensure consistency:**

```bash
# Build the image locally with a test tag
docker build -t ragedunicorn/busted:test .
```

**Linux/macOS:**

```bash
# Run tests against your local build
BUSTED_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

**Windows (PowerShell):**

```powershell
# Run tests against your local build
$env:BUSTED_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

**Windows (Command Prompt):**

```cmd
# Run tests against your local build
set BUSTED_VERSION=test && docker compose -f docker-compose.test.yml run test-all
```

**Why local testing is important:**

- Remote images (Docker Hub, GHCR) may have different labels due to CI/CD overrides
- Ensures you're testing exactly what you built
- Avoids false positives/negatives from version mismatches
- Guarantees consistent test results

**Never pull remote images for testing:**

**❌ DON'T DO THIS - may have different labels/settings:**

```bash
docker pull ragedunicorn/busted:latest
docker compose -f docker-compose.test.yml run test-all
```

**✅ DO THIS - test your local build:**

Linux/macOS:

```bash
docker build -t ragedunicorn/busted:test .
BUSTED_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

Windows (PowerShell):

```powershell
docker build -t ragedunicorn/busted:test .
$env:BUSTED_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

### Test Execution

Run all tests against your local build:

**Linux/macOS:**

```bash
# Ensure you've built locally first!
BUSTED_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

**Windows (PowerShell):**

```powershell
# Ensure you've built locally first!
$env:BUSTED_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

**Windows (Command Prompt):**

```cmd
# Ensure you've built locally first!
set BUSTED_VERSION=test && docker compose -f docker-compose.test.yml run test-all
```

Run specific test categories:

**Linux/macOS:**

```bash
# File structure and library tests
BUSTED_VERSION=test docker compose -f docker-compose.test.yml up container-test

# Command execution and spec-running tests
BUSTED_VERSION=test docker compose -f docker-compose.test.yml up container-test-command

# Metadata and label tests
BUSTED_VERSION=test docker compose -f docker-compose.test.yml up container-test-metadata
```

**Windows (PowerShell):**

```powershell
# File structure and library tests
$env:BUSTED_VERSION="test"; docker compose -f docker-compose.test.yml up container-test

# Command execution and spec-running tests
$env:BUSTED_VERSION="test"; docker compose -f docker-compose.test.yml up container-test-command

# Metadata and label tests
$env:BUSTED_VERSION="test"; docker compose -f docker-compose.test.yml up container-test-metadata
```

### Testing Different Versions

When testing different versions, always build locally first:

```bash
# Build a specific version locally
docker build -t ragedunicorn/busted:2.2.0-alpine3.23.4-1 .
```

**Linux/macOS:**

```bash
# Test that specific version
BUSTED_VERSION=2.2.0-alpine3.23.4-1 docker compose -f docker-compose.test.yml run test-all
```

**Windows (PowerShell):**

```powershell
# Test that specific version
$env:BUSTED_VERSION="2.2.0-alpine3.23.4-1"; docker compose -f docker-compose.test.yml run test-all
```

## Troubleshooting Test Failures

### Docker-in-Docker Issues

Container Structure Tests require access to the Docker daemon. If tests fail with "no such image" errors when run through docker-compose, run the tests directly:

```bash
# Run tests directly
docker run --rm -v $(pwd)/test:/test:ro -v /var/run/docker.sock:/var/run/docker.sock \
  ragedunicorn/container-test:latest test --image ragedunicorn/busted:test \
  --config /test/busted_test.yml
```

### Metadata Test Failures

**Common causes:**

1. **Testing remote images instead of local builds**
   - Remote images (Docker Hub, GHCR) have labels overridden by CI/CD
   - Always test your local builds with `BUSTED_VERSION=test`

2. **Label value mismatches**
   - CI/CD systems may capitalize values (e.g., "RagedUnicorn" vs "ragedunicorn")
   - GitHub Actions may override labels during build
   - Docker Hub automated builds may set different values

3. **Version-specific labels**
   - The `org.opencontainers.image.version` label changes with each build
   - Build date labels are dynamic

**Solution:** Always build and test locally before pushing:

```bash
docker build -t ragedunicorn/busted:test .
```

Linux/macOS:

```bash
BUSTED_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

Windows (PowerShell):

```powershell
$env:BUSTED_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

### Permission Errors

If you encounter Docker socket permission errors:

```bash
sudo docker compose -f docker-compose.test.yml run test-all
```

Or ensure your user is in the `docker` group:

```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

## Writing New Tests

To add new tests, follow the Container Structure Test schema:

1. **File tests**: Add to `test/busted_test.yml`
2. **Command tests**: Add to `test/busted_command_test.yml`
3. **Metadata tests**: Add to `test/busted_metadata_test.yml`

Example of adding a new formatter test:

```yaml
- name: 'Test gtest formatter'
  command: 'busted'
  args: ['--output=gtest', '/tmp/spec/test_spec.lua']
  setup: [
    ['sh', '-c', 'mkdir -p /tmp/spec && printf ''describe("x", function() it("y", function() assert(true) end) end)\n'' > /tmp/spec/test_spec.lua']
  ]
  expectedOutput:
    - 'PASSED'
  exitCode: 0
```

## CI/CD Integration

These tests are automatically run in GitHub Actions:

- **On every push** to master branches
- **On every pull request** to master branches
- **Before releases** to ensure quality

The test workflow (`.github/workflows/test.yml`):
1. Builds the Docker image
2. Runs all Container Structure Tests
3. Verifies basic Busted functionality
4. Blocks releases if tests fail

Manual integration example:

```yaml
- name: Run Container Structure Tests
  env:
    BUSTED_VERSION: test
  run: docker compose -f docker-compose.test.yml run test-all
```

The `test-all` service returns:
- Exit code 0: All tests passed
- Exit code 1: One or more tests failed

## Test Maintenance

When updating the Docker image:

1. **Busted version updates**: Update version tests if output format changes
2. **Alpine version updates**: Usually no test changes needed
3. **New formatter additions**: Add corresponding tests to verify functionality
4. **Label changes**: Update metadata tests to match new labels

Always run the full test suite before creating a release.
