############################################
# Busted build stage
############################################
FROM alpine:3.24.1 AS build

# renovate: datasource=github-releases depName=lunarmodules/busted
ARG BUSTED_VERSION=2.3.0
ARG PREFIX=/opt/busted

# Build stage labels
LABEL org.opencontainers.image.authors="Michael Wiesendanger <michael.wiesendanger@gmail.com>" \
      org.opencontainers.image.source="https://github.com/RagedUnicorn/docker-busted" \
      org.opencontainers.image.licenses="MIT"

# Install build dependencies
# luasystem (a busted dependency) contains C code and needs build tools
RUN apk add --no-cache --update \
    build-base \
    curl \
    git \
    lua5.3 \
    lua5.3-dev \
    luarocks5.3

WORKDIR /tmp/build

RUN luarocks-5.3 install busted ${BUSTED_VERSION}

############################################
# Runtime stage
############################################
FROM alpine:3.24.1

ARG BUILD_DATE
ARG VERSION

# OCI-compliant labels
LABEL org.opencontainers.image.title="Busted on Alpine Linux" \
      org.opencontainers.image.description="Lightweight Busted Docker image built on Alpine Linux for Lua unit testing" \
      org.opencontainers.image.vendor="ragedunicorn" \
      org.opencontainers.image.authors="Michael Wiesendanger <michael.wiesendanger@gmail.com>" \
      org.opencontainers.image.source="https://github.com/RagedUnicorn/docker-busted" \
      org.opencontainers.image.documentation="https://github.com/RagedUnicorn/docker-busted/blob/master/README.md" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.base.name="docker.io/library/alpine:3.24.1"

# Install runtime dependencies only
# libstdc++ is required by luasystem at runtime
RUN apk add --no-cache --update \
    lua5.3 \
    libstdc++

# Copy busted and all dependencies from build stage
COPY --from=build /usr/local /usr/local

WORKDIR /workspace

# Set the entrypoint to busted binary
ENTRYPOINT ["busted"]

# Default to showing help if no arguments provided
CMD ["--help"]
