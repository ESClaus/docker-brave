#!/usr/bin/env bash
#
# Smoke test for docker-brave images.
#
# Starts a container with an EMPTY /config directory and verifies that it stays
# running and serves the web interface. The empty-profile case is deliberate:
# both the "profile in use" bug and the Brave 1.92 wallet crash only reproduced
# on a first run, and were missed for months because manual testing always
# reused an existing profile directory.
#
# Usage:
#   ./scripts/smoke-test.sh <image> [port]
#
# Examples:
#   ./scripts/smoke-test.sh docker-brave:local
#   ./scripts/smoke-test.sh esclaus/docker-brave:origin-latest 5899
#
# Exits 0 on success, non-zero on failure.

set -eu

IMAGE="${1:-}"
PORT="${2:-5899}"

if [ -z "$IMAGE" ]; then
    echo "usage: $0 <image> [port]" >&2
    exit 2
fi

# How long to wait for the web interface before giving up.
TIMEOUT_SECONDS=90
# How long the container must stay up after responding, to catch delayed exits.
STABILITY_SECONDS=15

CONTAINER="smoke-$$"
CONFIG_DIR="$(mktemp -d)"

cleanup() {
    docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
    # The container chowns /config to its own UID. On a real bind mount (Linux)
    # the host user may no longer be able to delete it, so this is best-effort.
    rm -rf "$CONFIG_DIR" 2>/dev/null || true
}
trap cleanup EXIT

fail() {
    echo ""
    echo "FAIL: $1"
    echo ""
    echo "--- container status ---"
    docker inspect -f 'Running={{.State.Running}} ExitCode={{.State.ExitCode}} Error={{.State.Error}}' \
        "$CONTAINER" 2>&1 || true
    echo ""
    echo "--- docker logs (last 40) ---"
    docker logs "$CONTAINER" 2>&1 | tail -40 || true
    echo ""
    echo "--- brave error.log (last 30) ---"
    # Brave's own stderr is redirected here by the container and does NOT
    # appear in docker logs. The SIGTRAP wallet crash was only visible here.
    #
    # Read it from inside the container: the container chowns /config to its
    # own UID, so on a Linux bind mount the host user often cannot read it.
    docker exec "$CONTAINER" tail -30 /config/log/brave/error.log 2>/dev/null \
        || docker run --rm -v "${CONFIG_DIR}:/c:ro" --entrypoint /bin/sh "$IMAGE" \
             -c 'tail -30 /c/log/brave/error.log' 2>/dev/null \
        || echo "(not readable)"
    exit 1
}

echo "Image:  $IMAGE"
echo "Port:   $PORT"
echo "Config: $CONFIG_DIR (empty, fresh profile)"
echo ""

docker rm -f "$CONTAINER" >/dev/null 2>&1 || true

docker run -d \
    --name="$CONTAINER" \
    -p "${PORT}:5800" \
    -v "${CONFIG_DIR}:/config" \
    --shm-size=1gb \
    "$IMAGE" >/dev/null

echo -n "Waiting for web interface"
elapsed=0
while [ "$elapsed" -lt "$TIMEOUT_SECONDS" ]; do
    running="$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null || echo false)"
    if [ "$running" != "true" ]; then
        echo ""
        fail "container exited after ${elapsed}s (expected it to stay running)"
    fi

    if curl -fsS -o /dev/null --max-time 5 "http://localhost:${PORT}/" 2>/dev/null; then
        echo " ok (${elapsed}s)"
        break
    fi

    echo -n "."
    sleep 3
    elapsed=$((elapsed + 3))
done

if [ "$elapsed" -ge "$TIMEOUT_SECONDS" ]; then
    echo ""
    fail "web interface did not respond within ${TIMEOUT_SECONDS}s"
fi

echo -n "Confirming stability for ${STABILITY_SECONDS}s"
sleep "$STABILITY_SECONDS"
running="$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null || echo false)"
if [ "$running" != "true" ]; then
    echo ""
    fail "container exited during the stability window"
fi
echo " ok"

# The profile directory should have been populated. An empty one means Brave
# never really started, even if the VNC layer is serving pages.
#
# Checked inside the container rather than on the host: /config is chowned to
# the container's UID, so the host user may not be able to read it at all.
if ! docker exec "$CONTAINER" test -f "/config/profile/Local State"; then
    fail "Brave did not initialise a profile (no /config/profile/Local State)"
fi
echo "Profile initialised: ok"

echo ""
echo "PASS: $IMAGE"