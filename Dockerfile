############################################
# Busted runtime image
############################################
FROM alpine:3.24.3

# Version of the Alpine lua5.3-busted package. Installed with apk's fuzzy
# '~' match, so any Alpine package revision (-rN) of this upstream release is
# accepted while the release itself stays pinned.
# renovate: datasource=github-releases depName=lunarmodules/busted
ARG BUSTED_VERSION=2.3.0
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
      org.opencontainers.image.base.name="docker.io/library/alpine:3.24.3"

# Busted and its dependencies (luassert, penlight, luasystem, ...) from the
# Alpine main repository. The packages are signed by Alpine and their versions
# are fixed by the base image release, unlike a luarocks install that resolves
# unpinned transitive rocks from luarocks.org at build time.
RUN apk add --no-cache \
    lua5.3 \
    "lua5.3-busted~${BUSTED_VERSION}"

# lua5.3-busted only ships the versioned busted-5.3 launcher. The generic
# lua-busted package would add /usr/bin/busted, but it targets Alpine's
# default Lua rather than 5.3, so link the 5.3 launcher instead.
RUN ln -s /usr/bin/busted-5.3 /usr/bin/busted

# Non-root user so spec code does not run as container root
RUN adduser -D -s /sbin/nologin busted

WORKDIR /workspace
RUN chown -R busted:busted /workspace

USER busted

# Set the entrypoint to busted binary
ENTRYPOINT ["busted"]

# Default to showing help if no arguments provided
CMD ["--help"]
