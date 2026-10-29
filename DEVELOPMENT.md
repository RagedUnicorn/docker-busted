# Development Guide

This document provides information for developers working on the Busted Docker image.

## Development Environment

### Prerequisites

- Docker installed and running
- Docker Compose installed
- Git for version control
- Text editor or IDE

### Project Structure

```
docker-busted/
├── Dockerfile              # Main image definition
├── docker-compose.yml      # Basic usage configuration
├── docker-compose.dev.yml  # Development environment
├── docker-compose.test.yml # Test orchestration
├── .env                    # Default environment variables
├── examples/               # Example Docker Compose configurations
│   ├── docker-compose.test.yml
│   ├── docker-compose.ci.yml
│   ├── .busted
│   └── spec/
│       ├── calculator_spec.lua
│       └── string_utils_spec.lua
├── test/                   # Container Structure Tests
│   ├── busted_test.yml
│   ├── busted_command_test.yml
│   └── busted_metadata_test.yml
└── docs/                   # Documentation assets
```

## Development Workflow

### 1. Local Development Mode

The `docker-compose.dev.yml` file provides an interactive development environment:

```bash
# Build the image locally
docker compose -f docker-compose.dev.yml build

# Run in development mode (interactive shell)
docker compose -f docker-compose.dev.yml run --rm busted-dev

# Inside the container, you can run busted manually
busted --version
busted --help
busted /workspace/spec
```

The development mode:

- Overrides the entrypoint to `/bin/sh` for interactive access
- Mounts the `./examples` directory at `/workspace` for testing specs
- Sets a custom prompt to identify the development environment
- Keeps STDIN open and allocates a TTY

### 2. Building the Image

```bash
# Basic build
docker build -t ragedunicorn/busted:dev .

# Build with specific versions (BUSTED_VERSION must be a release the
# Alpine base image ships as lua5.3-busted)
docker build \
  --build-arg BUSTED_VERSION=2.3.0 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VERSION=2.3.0-alpine3.24.3-1 \
  -t ragedunicorn/busted:2.3.0-alpine3.24.3-1 .

# Multi-platform build (requires buildx)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ragedunicorn/busted:dev .
```

### 3. Testing Your Changes

After making changes, always build and test locally:

```bash
# Build your changes locally
docker build -t ragedunicorn/busted:test .
```

#### Running Tests (Cross-Platform)

**Linux/macOS:**

```bash
# Run all tests against your local build
BUSTED_TEST_VERSION=test docker compose -f docker-compose.test.yml run test-all

# Run specific tests during development
BUSTED_TEST_VERSION=test docker compose -f docker-compose.test.yml up container-test-command
```

**Windows Command Prompt:**

```cmd
# Run all tests against your local build
set BUSTED_TEST_VERSION=test && docker compose -f docker-compose.test.yml run test-all

# Run specific tests during development
set BUSTED_TEST_VERSION=test && docker compose -f docker-compose.test.yml up container-test-command
```

**Windows PowerShell:**

```powershell
# Run all tests against your local build
$env:BUSTED_TEST_VERSION="test"; docker compose -f docker-compose.test.yml run test-all

# Run specific tests during development
$env:BUSTED_TEST_VERSION="test"; docker compose -f docker-compose.test.yml up container-test-command
```

**Important:** Never test against remote images - they may have different labels or configurations due to CI/CD overrides.

See [TEST.md](TEST.md) for detailed testing information.

### 4. Smoke-Testing With the Sample Specs

The `examples/` directory ships with a small spec suite you can use to confirm
the image actually runs Busted end-to-end:

```bash
docker run --rm -v "$(pwd)/examples:/workspace" ragedunicorn/busted:test spec
```

You should see green dots for each `it(...)` block and a summary like
`14 successes / 0 failures / 0 errors / 1 pending`.

## Making Changes

### Version Updates

This project uses [Renovate](https://docs.renovatebot.com/) to automatically manage dependency updates:

- **Busted**: Renovate monitors GitHub releases and creates PRs for new versions.
  Busted is installed from the Alpine `lua5.3-busted` package with apk's fuzzy
  `~` match, so a new upstream release only builds once the Alpine base image
  ships it; such a PR may have to wait for (or be combined with) an Alpine bump
- **Alpine Linux**: Renovate monitors Docker Hub via the Docker datasource on the
  `FROM` lines; regex `customManagers` in `renovate.json` also keep the
  `org.opencontainers.image.base.name` label in the Dockerfile and the matching
  value in `test/busted_metadata_test.yml` in sync, so all of these update
  together in one PR.

When Renovate creates a PR:

1. Review the changes in the PR
2. Check the CI/CD pipeline passes all tests
3. Test the build locally if it's a major version update
4. Merge the PR if everything looks good

Manual version updates are rarely needed, but if required:

```dockerfile
# Busted version
ARG BUSTED_VERSION=2.3.0

# Alpine base image
FROM alpine:3.24.3
```

When manually updating the Alpine version, update all spots together — the
`FROM alpine:X.Y.Z` line, the `org.opencontainers.image.base.name` label in the
Dockerfile, and the matching value in `test/busted_metadata_test.yml` — since
they are otherwise only kept in sync automatically by Renovate.

When manually updating versions:

1. Update the `FROM alpine:X.Y.Z` line in the Dockerfile
2. Update the `org.opencontainers.image.base.name` label and the metadata test value to match
3. Update `ARG BUSTED_VERSION=X.Y.Z` in the Dockerfile to the `lua5.3-busted`
   version the Alpine release ships (`apk search -x lua5.3-busted`)
4. Test the build thoroughly
5. Update version numbers in documentation
6. Run the full test suite

### Adding New Features

1. Update the Dockerfile if needed
2. Update README.md to document the feature
3. Add tests to verify the feature works:
   - Add command test in `test/busted_command_test.yml`
   - Add file test in `test/busted_test.yml` if applicable
4. Test the build locally
5. Update examples if the feature enables new use cases

Example of adding a new formatter test:

```yaml
# In test/busted_command_test.yml
- name: 'Test gtest formatter'
  command: 'busted'
  args: ['--output=gtest', '/tmp/spec/sample_spec.lua']
  setup: [
    ['sh', '-c', 'mkdir -p /tmp/spec && printf ''describe("x", function() it("y", function() assert(true) end) end)\n'' > /tmp/spec/sample_spec.lua']
  ]
  expectedOutput:
    - 'PASSED'
  exitCode: 0
```

## Code Style and Best Practices

### Dockerfile Best Practices

1. **Prefer Alpine packages**: Install signed apk packages instead of fetching from language registries at build time
2. **Layer optimization**: Group related commands to minimize layers
3. **Cache efficiency**: Order commands from least to most frequently changed
4. **Security**: Don't include build tools in the final image
5. **Labels**: Follow OCI naming conventions

### Documentation

1. **README.md**: Keep focused on user-facing information
2. **Comments**: Add comments in Dockerfile for complex operations
3. **Examples**: Provide working examples for new features
4. **Commit messages**: Use conventional format (feat:, fix:, docs:, etc.)

### Testing

1. **Test everything**: New features must include tests
2. **Test edge cases**: Include negative tests where appropriate
3. **Keep tests fast**: Avoid long-running operations in tests
4. **Test organization**: Group related tests together

## Debugging

### Common Issues

**Build failures:**

```bash
# Verbose build output
docker build --progress=plain --no-cache -t ragedunicorn/busted:debug .
```

**Busted not found:**

```bash
# Check installation paths
docker run --rm --entrypoint sh ragedunicorn/busted:dev -c "which busted"
docker run --rm --entrypoint sh ragedunicorn/busted:dev -c "ls -la /usr/bin/busted*"
```

**Lua module issues:**

```bash
# Check Lua paths
docker run --rm --entrypoint sh ragedunicorn/busted:dev -c "lua5.3 -e 'print(package.path)'"
docker run --rm --entrypoint sh ragedunicorn/busted:dev -c "lua5.3 -e 'print(package.cpath)'"

# Verify luassert can be loaded
docker run --rm --entrypoint sh ragedunicorn/busted:dev -c "lua5.3 -e 'require\"luassert\" print(\"ok\")'"

# List installed busted/luassert files
docker run --rm --entrypoint sh ragedunicorn/busted:dev -c "apk info -L lua5.3-busted lua5.3-luassert"
```

**Permission issues:**

```bash
# Check user and permissions
docker run --rm --entrypoint sh ragedunicorn/busted:dev -c "id"
docker run --rm --entrypoint sh ragedunicorn/busted:dev -c "ls -la /workspace"
```

## Contributing

### Before Submitting Changes

1. Run the full test suite
2. Update documentation if needed
3. Add tests for new features
4. Ensure your code follows the existing style
5. Write clear commit messages

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes using conventional commits
4. Push to your fork
5. Open a Pull Request with a clear description

### Release Process

See [RELEASE.md](RELEASE.md) for information about creating releases.
