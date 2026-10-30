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
- **Busted**: Installed from Alpine's signed `lua5.3-busted` package
- **Reproducible**: All Lua dependencies come from the Alpine release, nothing is fetched from LuaRocks
- **Volume mounting**: Easy spec input through `/workspace`
- **Non-root user**: runs as the unprivileged `busted` user
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

On Windows, use the PowerShell form:

```powershell
# Run Busted on your spec directory
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest spec

# Run a single spec file
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest spec/my_spec.lua
```

Write `${PWD}` **with braces** and keep the colon inside the quotes - without
braces PowerShell parses `$PWD:` as a scope-qualified variable (as in
`$env:PATH`) and rejects the argument. See the
[Windows (PowerShell) notes](#windows-powershell-notes) for details.

For development and building from source, see [DEVELOPMENT.md](DEVELOPMENT.md).

## Usage

The container uses Busted as the entrypoint, so any Busted parameters can be passed directly to the `docker run` command.

### Basic Usage

```bash
# Using latest version
docker run -v $(pwd):/workspace ragedunicorn/busted:latest [busted-options]

# Using specific Busted version (latest Alpine build)
docker run -v $(pwd):/workspace ragedunicorn/busted:<busted-version> [busted-options]

# Using exact version combination
docker run -v $(pwd):/workspace ragedunicorn/busted:<busted-version>-alpine<alpine-version>-<build> [busted-options]
```

PowerShell:

```powershell
# Using latest version
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest [busted-options]

# Using specific Busted version (latest Alpine build)
docker run -v "${PWD}:/workspace" ragedunicorn/busted:<busted-version> [busted-options]

# Using exact version combination
docker run -v "${PWD}:/workspace" ragedunicorn/busted:<busted-version>-alpine<alpine-version>-<build> [busted-options]
```

Available tags are listed on [Docker Hub](https://hub.docker.com/r/ragedunicorn/busted/tags) and in the
[GitHub releases](https://github.com/RagedUnicorn/docker-busted/releases).

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

#### PowerShell

The same examples in PowerShell:

```powershell
# Run all specs in spec/
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest spec

# Run a single spec file
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest spec/my_spec.lua

# Run with verbose output
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest --verbose spec

# Filter tests by pattern
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest --filter "math" spec

# TAP, JUnit XML, JSON and plain (no colors) output
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest --output=TAP spec
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest --output=junit spec
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest --output=json spec
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest --output=plainTerminal spec

# Use the "ci" profile from a .busted configuration file
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest --run=ci

# Run with a custom pattern
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest --pattern=_test spec
```

### Windows (PowerShell) notes

The PowerShell variants differ from the bash ones only in the mount, which is
written `-v "${PWD}:/workspace"` instead of `-v $(pwd):/workspace`. The
spelling matters:

- Pasting the bash form into PowerShell breaks: PowerShell ends the argument
  after the `$(pwd)` subexpression, so `$(pwd):/workspace` reaches Docker as
  two arguments (`C:\path` and `:/workspace`) and the run fails with
  `invalid reference format`.
- `"$PWD:/workspace"` without braces is a parse error: PowerShell reads a
  colon after a variable as a scope qualifier (as in `$env:PATH`), and `/` is
  not a valid variable-name character.
- `"${PWD}:/workspace"` works: the braces end the variable name at `PWD`, the
  colon stays literal, and Docker splits the resulting `C:\path:/workspace`
  on the second colon because it recognises the `C:` drive prefix.

To check what the container actually sees under `/workspace`, run a
look-inside command:

```powershell
docker run --rm -v "${PWD}:/workspace" --entrypoint sh ragedunicorn/busted:latest -c 'pwd; ls -la /workspace'
```

The single quotes keep `pwd; ls -la /workspace` as one literal argument to
the container's `sh`, so the `;` runs inside the container - unquoted,
PowerShell would treat `;` as its own statement separator and run
`ls -la /workspace` on the host.

When redirecting a report to a file, prefer `Out-File -Encoding utf8` over
`>`: Windows PowerShell 5.1 writes `>` output as UTF-16, which most CI report
parsers reject (PowerShell 7 writes UTF-8 either way):

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest --output=junit spec | Out-File -Encoding utf8 busted-report.xml
```

Line endings are not a concern: Lua treats `\r\n` as ordinary whitespace, so
specs checked out with Windows (CRLF) line endings run unchanged.

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

3. **Persistent Settings**: The repository includes a `.env` file with default settings. You can modify it to set your preferred versions:
   ```env
   BUSTED_VERSION=<busted-version>-alpine<alpine-version>-<build>
   ```

4. **Bind-Mount Ownership**: The image runs as the non-root `busted` user. On Linux and macOS hosts, run the container as your own user so reports and coverage files written into a bind mount stay owned by you:
   ```bash
   docker run --rm --user "$(id -u):$(id -g)" -v "$(pwd)":/workspace ragedunicorn/busted:latest spec
   ```
   In Docker Compose, use `user: "${UID:-1000}:${GID:-1000}"` (as the `examples/docker-compose.ci.yml` services do). Windows hosts can skip this — Docker Desktop bind mounts do not carry Unix file ownership.

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

PowerShell:

```powershell
docker run -v "${PWD}:/workspace" ragedunicorn/busted:latest --run=ci
```

## Versioning

This project uses semantic versioning that matches the Docker image contents:

**Format:** `{busted_version}-alpine{alpine_version}-{build_number}`

Examples (`X.Y.Z` is the Busted version, `A.B.C` the Alpine version):
- `X.Y.Z-alpineA.B.C-1` - Busted X.Y.Z on Alpine A.B.C, build 1
- `X.Y.Z` - Most recent build of Busted X.Y.Z
- `latest` - Most recent stable release

The current tags are listed on [Docker Hub](https://hub.docker.com/r/ragedunicorn/busted/tags).

For detailed release process and versioning guidelines, see [RELEASE.md](RELEASE.md).

## Image Verification

Released images are signed with [cosign](https://docs.sigstore.dev/) keyless signing and carry SBOM and provenance attestations.

```bash
# Verify the signature (works for both ghcr.io/ragedunicorn/docker-busted and ragedunicorn/busted)
cosign verify ragedunicorn/busted:latest \
  --certificate-identity-regexp '^https://github.com/RagedUnicorn/docker-busted/\.github/workflows/docker_release\.yml@refs/tags/v' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com

# Inspect the SBOM and provenance attestations
docker buildx imagetools inspect ragedunicorn/busted:latest --format '{{ json .SBOM }}'
docker buildx imagetools inspect ragedunicorn/busted:latest --format '{{ json .Provenance }}'
```

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
