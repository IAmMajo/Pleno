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

# Copy DTOs and models
COPY ./DTOs ./DTOs
COPY ./backend/models ./backend/models

# Navigate to the poster-service directory
WORKDIR /build/backend/poster-service

# Copy Package files and resolve dependencies
COPY ./backend/poster-service/Package.* ./
RUN swift package resolve \
        $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

# Copy entire repo into container
COPY ./backend/poster-service/ ./

# Build the application
RUN swift build -c release \
                --static-swift-stdlib \
                -Xlinker -ljemalloc

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build/backend/poster-service -c release --show-bin-path)/App" ./

# Copy static swift backtracer binary to staging area
RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./

# Copy resources bundled by SPM to staging area
RUN find -L "$(swift build --package-path /build/backend/poster-service -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

# Copy any resources from the public directory and views directory if the directories exist
# Ensure that only the necessary permissions are set
RUN [ -d /build/backend/poster-service/Public ] && { \
        mv /build/backend/poster-service/Public ./Public && \
        chmod -R a-w ./Public; \
    } || true
RUN [ -d /build/backend/poster-service/Resources ] && { \
        mv /build/backend/poster-service/Resources ./Resources && \
        chmod -R a-w ./Resources; \
    } || true
RUN [ -d /build/backend/poster-service/Storage ] && { \
        mv /build/backend/poster-service/Storage ./Storage && \
        chmod -R a-w  ./Storage; \
    } || true



# ================================
# Run image
# ================================
FROM ubuntu:jammy

# Install essential packages
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
      libjemalloc2 \
      ca-certificates \
      tzdata \
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

# Ensure all further commands run as the vapor user
USER vapor:vapor

# Let Docker bind to port 80
EXPOSE 80

# Start the Vapor service when the image is run, default to listening on 80 in production environment
ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "80"]
