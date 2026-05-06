#
# brave Dockerfile
#
# https://github.com/ESClaus/docker-brave
#

# Build the membarrier check tool.
FROM alpine:3.14 AS membarrier
WORKDIR /tmp
COPY membarrier_check.c .
RUN apk --no-cache add build-base linux-headers
RUN gcc -static -o membarrier_check membarrier_check.c
RUN strip membarrier_check

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.23-v4.11.3

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG BRAVE_VERSION=1.89.145

# Define working directory.
WORKDIR /tmp

# Install Brave browser.
RUN \
    add-pkg --virtual build-dependencies curl && \
    ARCH="$(apk --print-arch)" && \
    if [ "$ARCH" = "x86_64" ]; then \
        DEB_ARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        DEB_ARCH="arm64"; \
    fi && \
    curl -# -L -o /tmp/brave.deb \
        "https://github.com/brave/brave-browser/releases/download/v${BRAVE_VERSION}/brave-browser_${BRAVE_VERSION}_${DEB_ARCH}.deb" && \
    add-pkg --virtual extract-dependencies dpkg && \
    dpkg -x /tmp/brave.deb /tmp/brave-pkg && \
    cp -r /tmp/brave-pkg/opt /opt/ && \
    ln -sf /opt/brave.com/brave/brave-browser /usr/bin/brave-browser && \
    rm -rf /tmp/brave.deb /tmp/brave-pkg && \
    del-pkg build-dependencies && \
    del-pkg extract-dependencies

# Install extra packages.
RUN \
    ARCH="$(apk --print-arch)" && \
    if [ "$ARCH" = "x86" ] || [ "$ARCH" = "x86_64" ]; then \
        libva_intel_driver="libva-intel-driver"; \
    fi && \
    add-pkg \
        # WebGL support.
        mesa-dri-gallium \
        mesa-va-gallium \
        ${libva_intel_driver:-} \
        # Audio support.
        libpulse \
        # Desktop notification support.
        libnotify \
        # Icons used by folder/file selection window.
        adwaita-icon-theme \
        # Used to send key presses to the X process.
        xdotool \
        # Font support.
        font-dejavu \
        # Needed for Brave's sandbox alternative.
        libstdc++ \
        && \
    # Remove unneeded icons.
    find /usr/share/icons/Adwaita -type d -mindepth 1 -maxdepth 1 -not -name 16x16 -not -name scalable -exec rm -rf {} ';' && \
    true

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/ESClaus/docker-brave/main/brave-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY --from=membarrier /tmp/membarrier_check /usr/bin/

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "Brave" && \
    set-cont-env APP_VERSION "$BRAVE_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Set public environment variables.
ENV \
    BRAVE_OPEN_URL= \
    BRAVE_KIOSK=0 \
    BRAVE_CUSTOM_ARGS=

# Metadata.
LABEL \
    org.label-schema.name="brave" \
    org.label-schema.description="Docker container for Brave Browser" \
    org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
    org.label-schema.vcs-url="https://github.com/ESClaus/docker-brave" \
    org.label-schema.schema-version="1.0"