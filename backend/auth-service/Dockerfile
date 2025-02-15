# ================================
# Build image
# ================================
FROM swift:6.0-jammy AS build

# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev

# Set up a build area
WORKDIR /build

# Copy kivop packages
COPY ./DTOs ./DTOs
COPY ./backend/models ./backend/models

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.

WORKDIR /build/backend/auth-service

COPY ./backend/auth-service/Package.* ./
RUN swift package resolve \
        $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

# Copy entire repo into container
COPY ./backend/auth-service/ ./

# Build everything, with optimizations, with static linking, and using jemalloc
# N.B.: The static version of jemalloc is incompatible with the static Swift runtime.
RUN swift build -c release \
                --static-swift-stdlib \
                -Xlinker -ljemalloc

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build/backend/auth-service -c release --show-bin-path)/App" ./

# Copy static swift backtracer binary to staging area
RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./

# Copy resources bundled by SPM to staging area
RUN find -L "$(swift build --package-path /build/backend/auth-service -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

# Copy any resources from the public directory and views directory if the directories exist
# Ensure that by default, neither the directory nor any of its contents are writable.
RUN [ -d /build/backend/auth-service/Public ] && { mv /build/backend/auth-service/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/backend/auth-service/Resources ] && { mv /build/backend/auth-service/Resources ./Resources && chmod -R a-w ./Resources; } || true

# ================================
# Run image
# ================================
FROM ubuntu:jammy

# Make sure all system packages are up to date, and install only essential packages.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
      libjemalloc2 \
      ca-certificates \
      tzdata \
      curl \
      openssl \
# If your app or its dependencies import FoundationNetworking, also install `libcurl4`.
      # libcurl4 \
# If your app or its dependencies import FoundationXML, also install `libxml2`.
      # libxml2 \
    && rm -r /var/lib/apt/lists/*

# Create a vapor user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Switch to the new home directory
WORKDIR /app

# Copy built executable and any staged resources from builder
COPY --from=build --chown=vapor:vapor /staging /app

# Provide configuration needed by the built-in crash reporter and some sensible default behaviors.
ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static


# ECDSA Key Validation & Generation
RUN mkdir -p /app/certs/jwt /app/certs/auth && \
    echo "Verzeichnisstruktur erstellt. Überprüfe Dateien..." && \
    ls -l /app/certs && \
    if [[ -f /app/certs/auth/private.pem && -f /app/certs/jwt/public.pem ]]; then \
        echo "ECDSA-Schlüsselpaar existiert, überprüfe Gültigkeit..."; \
        openssl ec -in /app/certs/auth/private.pem -check -noout && \
        openssl ec -in /app/certs/auth/private.pem -pubout | diff - /app/certs/jwt/public.pem && \
        echo "ECDSA-Schlüsselpaar ist gültig."; \
    else \
        echo "Schlüsselpaar existiert nicht oder ist ungültig. Erstelle ein neues..." && \
        openssl ecparam -name prime256v1 -genkey -noout -out /app/certs/auth/private.pem && \
        openssl ec -in /app/certs/auth/private.pem -pubout -out /app/certs/jwt/public.pem && \
        echo "Neues ECDSA-Schlüsselpaar erstellt."; \
    fi && \
    echo "Setze Berechtigungen und Besitz..." && \
    chown -R vapor:vapor /app/certs && \
    chmod 600 /app/certs/auth/private.pem && \
    chmod 644 /app/certs/jwt/public.pem && \
    echo "Berechtigungen und Besitz gesetzt." && \
    ls -l /app/certs    

# Ensure all further commands run as the vapor user
USER vapor:vapor

# Let Docker bind to port 80
EXPOSE 80

# Only specify this container as healthy if its service's /internal/healthcheck-route responds successfully
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --start-interval=3s --retries=3 CMD curl -f http://localhost/internal/healthcheck || exit 1

# Start the Vapor service when the image is run, default to listening on 80 in production environment
ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "80"]