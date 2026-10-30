# Busted Alpine Docker Image

![Docker Busted](https://raw.githubusercontent.com/RagedUnicorn/docker-busted/master/docs/docker_busted_banner.png)

A lightweight Busted build on Alpine Linux for fast and reliable Lua unit testing.

## Quick Start

```bash
# Pull latest version
docker pull ragedunicorn/busted:latest

# Or pull specific version (see the Tags tab for the available versions)
docker pull ragedunicorn/busted:<busted-version>-alpine<alpine-version>-<build>

# Run all specs in the spec/ directory
docker run -v $(pwd):/workspace ragedunicorn/busted:latest spec
```

On Windows, use the PowerShell form - `${PWD}` **with braces** and the colon
inside the quotes (without braces PowerShell parses `$PWD:` as a
scope-qualified variable, as in `$env:PATH`, and rejects the argument):

```powershell
# Run all specs in the spec/ directory
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest spec
```

## Features

- 🚀 **Small footprint**: Lightweight Alpine-based runtime image
- 📦 **Busted**: Installed from Alpine's signed `lua5.3-busted` package
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

PowerShell:

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest spec
```

### Run a single spec file

```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest spec/calculator_spec.lua
```

PowerShell:

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest spec/calculator_spec.lua
```

### Filter tests by name

```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest \
  --filter "math" spec
```

PowerShell:

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest `
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

PowerShell (`Out-File -Encoding utf8` instead of `>`, which Windows
PowerShell 5.1 writes as UTF-16):

```powershell
# JUnit format for CI systems
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest `
  --output=junit spec | Out-File -Encoding utf8 busted-report.xml

# TAP format
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest `
  --output=TAP spec
```

### Use a `.busted` configuration profile

```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest --run=ci
```

PowerShell:

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest --run=ci
```

## Tags

This image uses semantic versioning that includes all component versions:

**Format:** `{busted_version}-alpine{alpine_version}-{build_number}`

### Version Examples

`X.Y.Z` is the Busted version, `A.B.C` the Alpine version:

- `X.Y.Z-alpineA.B.C-1` - Busted X.Y.Z on Alpine A.B.C, build 1
- `X.Y.Z-alpineA.B.C-2` - Rebuild of same versions (bug fixes, optimizations)
- `X.Y.Z-alpineA.B.D-1` - Alpine Linux patch update (build resets to 1)
- `X.Y+1.0-alpineA.B.C-1` - Busted version update (build resets to 1)
- `X.Y.Z` - Most recent build of Busted X.Y.Z
- `latest` - Most recent stable release

The available versions are listed in the [Tags tab](https://hub.docker.com/r/ragedunicorn/busted/tags).

When updates are available through automated dependency management, new releases are created with appropriate version tags.

## Links

- **GitHub**: [https://github.com/RagedUnicorn/docker-busted](https://github.com/RagedUnicorn/docker-busted)
- **Issues**: [https://github.com/RagedUnicorn/docker-busted/issues](https://github.com/RagedUnicorn/docker-busted/issues)
- **Releases**: [https://github.com/RagedUnicorn/docker-busted/releases](https://github.com/RagedUnicorn/docker-busted/releases)

## License

MIT License - See [GitHub repository](https://github.com/RagedUnicorn/docker-busted) for details.
