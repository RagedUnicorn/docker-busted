# Busted Alpine Docker Image

![Docker Busted](https://raw.githubusercontent.com/RagedUnicorn/docker-busted/master/docs/docker_busted_banner.png)

A lightweight Busted build on Alpine Linux for fast and reliable Lua unit testing.

## Quick Start

```bash
# Pull latest version
docker pull ragedunicorn/busted:latest

# Or pull specific version
docker pull ragedunicorn/busted:2.3.0-alpine3.24.1-1

# Run all specs in the spec/ directory
docker run -v $(pwd):/workspace ragedunicorn/busted:latest spec
```

## Features

- 🚀 **Small footprint**: Lightweight Alpine-based runtime image
- 📦 **Busted 2.3.0**: Installed from Alpine's signed `lua5.3-busted` package
- 🔍 **Rich assertions**: Powered by `luassert` (mocks, spies, stubs)
- 🏗️ **Multi-platform**: Supports linux/amd64 and linux/arm64
- ⚡ **CI-friendly**: Built-in JUnit, TAP, JSON, and plain output formatters

## Supported Outputs

**Lua versions**: Lua 5.3 (default runtime in this image)
**Formatters**: utfTerminal, plainTerminal, TAP, junit, json, gtest

## Usage Examples

### Run all specs

```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest spec
```

### Run a single spec file

```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest spec/calculator_spec.lua
```

### Filter tests by name

```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest \
  --filter "math" spec
```

### Generate CI reports

```bash
# JUnit format for CI systems
docker run -v $(pwd):/workspace ragedunicorn/busted:latest \
  --output=junit spec > busted-report.xml

# TAP format
docker run -v $(pwd):/workspace ragedunicorn/busted:latest \
  --output=TAP spec
```

### Use a `.busted` configuration profile

```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest --run=ci
```

## Tags

This image uses semantic versioning that includes all component versions:

**Format:** `{busted_version}-alpine{alpine_version}-{build_number}`

### Version Examples

- `2.3.0-alpine3.24.1-1` - Busted 2.3.0 on Alpine 3.24.1, build 1
- `2.3.0-alpine3.24.1-2` - Rebuild of same versions (bug fixes, optimizations)
- `2.3.0-alpine3.24.3-1` - Alpine Linux patch update (build resets to 1)
- `2.4.0-alpine3.24.3-1` - Busted version update (build resets to 1)

When updates are available through automated dependency management, new releases are created with appropriate version tags.

## Links

- **GitHub**: [https://github.com/RagedUnicorn/docker-busted](https://github.com/RagedUnicorn/docker-busted)
- **Issues**: [https://github.com/RagedUnicorn/docker-busted/issues](https://github.com/RagedUnicorn/docker-busted/issues)
- **Releases**: [https://github.com/RagedUnicorn/docker-busted/releases](https://github.com/RagedUnicorn/docker-busted/releases)

## License

MIT License - See [GitHub repository](https://github.com/RagedUnicorn/docker-busted) for details.
