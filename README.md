# docker-busted

![](./docs/docker_busted_banner.svg)

[![Release Build](https://github.com/RagedUnicorn/docker-busted/actions/workflows/docker_release.yml/badge.svg)](https://github.com/RagedUnicorn/docker-busted/actions/workflows/docker_release.yml)
[![Test](https://github.com/RagedUnicorn/docker-busted/actions/workflows/test.yml/badge.svg)](https://github.com/RagedUnicorn/docker-busted/actions/workflows/test.yml)
![License: MIT](docs/license_badge.svg)

> Docker Alpine image with Busted - An elegant Lua unit testing framework.

## Overview

This Docker image provides a lightweight Busted installation on Alpine Linux. Busted is a unit testing framework with a rich set of features designed for Lua. It supports BDD-style spec syntax (`describe`, `it`), asynchronous tests, mocks, spies, and stubs through `luassert`, and a variety of output formatters for both terminal and CI use.

## Features

- **Small footprint**: Lightweight runtime image using Alpine Linux
- **Busted 2.2.0**: Latest stable version installed via LuaRocks
- **Multi-stage build**: Optimized for minimal final image size
- **Volume mounting**: Easy spec input through `/workspace`
- **Multiple formatters**: utfTerminal, plainTerminal, TAP, junit, json, gtest

## Quick Start

```bash
# Pull the image
docker pull ragedunicorn/busted:latest

# Run Busted on your spec directory
docker run -v $(pwd):/workspace ragedunicorn/busted:latest spec

# Run a single spec file
docker run -v $(pwd):/workspace ragedunicorn/busted:latest spec/my_spec.lua
```

For development and building from source, see [DEVELOPMENT.md](DEVELOPMENT.md).

## Usage

The container uses Busted as the entrypoint, so any Busted parameters can be passed directly to the `docker run` command.

### Basic Usage

```bash
# Using latest version
docker run -v $(pwd):/workspace ragedunicorn/busted:latest [busted-options]

# Using specific Busted version (latest Alpine build)
docker run -v $(pwd):/workspace ragedunicorn/busted:2.2.0 [busted-options]

# Using exact version combination
docker run -v $(pwd):/workspace ragedunicorn/busted:2.2.0-alpine3.23.4-1 [busted-options]
```

### Examples

#### Run All Specs in `spec/`
```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest spec
```

#### Run a Single Spec File
```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest spec/my_spec.lua
```

#### Run with Verbose Output
```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest --verbose spec
```

#### Filter Tests by Pattern
```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest --filter "math" spec
```

#### Generate Output in a Specific Format
```bash
# TAP format
docker run -v $(pwd):/workspace ragedunicorn/busted:latest --output=TAP spec

# JUnit XML format
docker run -v $(pwd):/workspace ragedunicorn/busted:latest --output=junit spec

# JSON format
docker run -v $(pwd):/workspace ragedunicorn/busted:latest --output=json spec

# Plain (no colors) for CI logs
docker run -v $(pwd):/workspace ragedunicorn/busted:latest --output=plainTerminal spec
```

#### Use a Configuration File
A `.busted` configuration file in your project root is picked up automatically:

```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest --run=ci
```

#### Run with a Custom Pattern
```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest --pattern=_test spec
```

## Docker Compose Usage

This repository includes Docker Compose configurations for easier usage and common testing workflows.

### Basic Setup

1. Place your Lua spec files in a `spec/` directory in your project

2. Run Busted using docker compose:
```bash
docker compose run --rm busted
```

### Example Configurations

The `examples/` directory contains specialized docker-compose files for common tasks:

#### Project Testing (`examples/docker-compose.test.yml`)
```bash
# Run all specs
docker compose -f examples/docker-compose.test.yml run --rm test-all

# Run with verbose output
docker compose -f examples/docker-compose.test.yml run --rm test-verbose

# Run only matching tests
docker compose -f examples/docker-compose.test.yml run --rm test-filter
```

#### CI/CD Integration (`examples/docker-compose.ci.yml`)
```bash
# Generate JUnit report for CI
docker compose -f examples/docker-compose.ci.yml run --rm ci-junit

# Generate TAP report
docker compose -f examples/docker-compose.ci.yml run --rm ci-tap

# Plain check with exit code only
docker compose -f examples/docker-compose.ci.yml run --rm ci-check
```

### Environment Variables

The compose services support environment variables for customization:

- `BUSTED_VERSION`: Specify Busted image version (default: latest)
- See individual compose files for more options

### Tips

1. **Custom Commands**: Override the default command:
   ```bash
   docker compose run --rm busted --output=TAP --verbose spec
   ```

2. **Configuration File**: Create a `.busted` file in your project root for persistent settings (see `examples/.busted`)

3. **Persistent Settings**: The repository includes a `.env` file with default settings

## Configuration

Busted can be configured using a `.busted` file. Here's an example:

```lua
return {
  default = {
    verbose = true,
    output = "utfTerminal",
    ROOT = {"spec"},
    pattern = "_spec",
  },
  ci = {
    output = "junit",
    ROOT = {"spec"},
    pattern = "_spec",
  },
}
```

Run a named profile with `--run=<name>`:

```bash
docker run -v $(pwd):/workspace ragedunicorn/busted:latest --run=ci
```

## Versioning

This project uses semantic versioning that matches the Docker image contents:

**Format:** `{busted_version}-alpine{alpine_version}-{build_number}`

Examples:
- `2.2.0-alpine3.23.4-1` - Busted 2.2.0 on Alpine 3.23.4, build 1
- `latest` - Most recent stable release

For detailed release process and versioning guidelines, see [RELEASE.md](RELEASE.md).

## Automated Dependency Updates

This project uses [Renovate](https://docs.renovatebot.com/) to automatically check for updates to:
- Alpine Linux base image version
- Busted version

Renovate runs weekly and creates pull requests when updates are available.

## Documentation

- [Development Guide](DEVELOPMENT.md) - Building, debugging, and contributing
- [Testing Guide](TEST.md) - Running and writing tests
- [Release Process](RELEASE.md) - Creating releases and versioning

## Links

- [Busted Documentation](https://lunarmodules.github.io/busted/)
- [luassert Documentation](https://github.com/lunarmodules/luassert)
- [Alpine Linux](https://www.alpinelinux.org/)

# License

MIT License

Copyright (c) 2026 Michael Wiesendanger

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
