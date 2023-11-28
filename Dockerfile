# ================================
# Build image
# ================================
FROM swift:5.9.1-jammy

# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y\
    && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

ARG CONFIG
ENV CONFIG=${CONFIG}

# Build everything, with optimizations
RUN --mount=type=cache,target=/build/.build \
    swift \
    build \
    -c $CONFIG \
    --static-swift-stdlib

RUN swift \
    test

ENTRYPOINT ["swift", "test"]