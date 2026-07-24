#!/usr/bin/env bash
#
# Check whether a Brave version is published on GitHub releases for every
# flavor and architecture this repository builds.
#
# Run this before bumping ARG BRAVE_VERSION in the Dockerfile. A missing asset
# here means the build will fail in CI with a 404 from curl, which is a much
# slower and less obvious way to find out.
#
# Usage:
#   ./scripts/check-version.sh 1.93.100
#   ./scripts/check-version.sh            (prompts for the version)
#
# Exits 0 if every asset is present, 1 otherwise.

set -eu

FLAVORS="brave-browser brave-origin"
ARCHES="amd64 arm64"
BASE_URL="https://github.com/brave/brave-browser/releases/download"

VERSION="${1:-}"

if [ -z "$VERSION" ]; then
    printf 'Brave version to check (for example 1.93.100): '
    read -r VERSION
fi

# Strip a leading "v" if it was pasted from a release tag.
VERSION="${VERSION#v}"

# Sanity check the shape before firing off eight requests.
if ! echo "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "Not a valid version: '$VERSION' (expected something like 1.93.100)" >&2
    exit 2
fi

echo "Checking Brave $VERSION"
echo ""

MISSING=0

for flavor in $FLAVORS; do
    for arch in $ARCHES; do
        asset="${flavor}_${VERSION}_${arch}.deb"
        url="${BASE_URL}/v${VERSION}/${asset}"

        # -I sends a HEAD request, so nothing is downloaded.
        # -L follows the redirect GitHub issues to its asset storage.
        code="$(curl -sIL -o /dev/null -w '%{http_code}' --max-time 20 "$url" || echo 000)"

        if [ "$code" = "200" ]; then
            printf '  ok      %s\n' "$asset"
        else
            printf '  MISSING %s (HTTP %s)\n' "$asset" "$code"
            MISSING=$((MISSING + 1))
        fi
    done
done

echo ""

if [ "$MISSING" -ne 0 ]; then
    echo "$MISSING asset(s) missing. Do not bump the Dockerfile yet."
    echo ""
    echo "If only one flavor is missing, the two channels have fallen out of"
    echo "lockstep. The CI workflow builds both from a single BRAVE_VERSION, so"
    echo "that assumption needs revisiting before this version can ship."
    exit 1
fi

echo "All assets present."
echo ""
echo "Next steps:"
echo "  1. Set ARG BRAVE_VERSION=$VERSION in the Dockerfile"
echo "  2. docker build --build-arg BRAVE_FLAVOR=brave-browser --build-arg BRAVE_VERSION=$VERSION -t docker-brave:local ."
echo "  3. docker build --build-arg BRAVE_FLAVOR=brave-origin  --build-arg BRAVE_VERSION=$VERSION -t docker-brave:origin ."
echo "  4. ./scripts/smoke-test.sh docker-brave:local"
echo "  5. ./scripts/smoke-test.sh docker-brave:origin 5898"