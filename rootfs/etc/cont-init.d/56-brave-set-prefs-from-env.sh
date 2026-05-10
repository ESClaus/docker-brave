#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Make sure the Brave profile directory exists.
mkdir -p /config/profile/Default

# Disable the session restore bubble by setting the exit type to normal.
LOCAL_STATE="/config/profile/Local State"
if [ -f "$LOCAL_STATE" ]; then
    # Set exit type to Normal to prevent restore dialog.
    sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/g' "$LOCAL_STATE"
    sed -i 's/"exit_type": "Crashed"/"exit_type": "Normal"/g' "$LOCAL_STATE"
fi

# vim:ft=sh:ts=4:sw=4:et:sts=4