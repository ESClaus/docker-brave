#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Make sure some directories are created.
mkdir -p /config/Downloads
mkdir -p /config/log/brave
mkdir -p /config/profile

# Generate machine id.
if [ ! -f /config/machine-id ]; then
    echo "generating machine-id..."
    cat /proc/sys/kernel/random/uuid | tr -d '-' > /config/machine-id
fi

# Initialize log files.
for LOG_FILE in /config/log/brave/output.log /config/log/brave/error.log
do
    touch "$LOG_FILE"

    # Make sure the file doesn't grow indefinitely.
    if [ "$(stat -c %s "$LOG_FILE")" -gt 1048576 ]; then
       echo > "$LOG_FILE"
    fi
done

# Remove stale Brave profile lock files left over from unclean shutdowns.
for LOCK_FILE in \
    /config/profile/SingletonLock \
    /config/profile/SingletonSocket \
    /config/profile/SingletonCookie
do
    if [ -e "$LOCK_FILE" ] || [ -L "$LOCK_FILE" ]; then
        echo "Removing stale lock file: $LOCK_FILE"
        rm -f "$LOCK_FILE"
    fi
done

# Remove stale Brave crashpad lock files left over from unclean shutdowns.
for CRASHPAD_PENDING_DIR in "/config/xdg/config/BraveSoftware/"*"/Crash Reports/pending"
do
    if [ -d "$CRASHPAD_PENDING_DIR" ]; then
        echo "cleaning crashpad locks in $CRASHPAD_PENDING_DIR..."
        find "$CRASHPAD_PENDING_DIR" -name "*.lock" -exec rm -f {} \;
    fi
done

# Clear stale process tracking from Local State to prevent
# "profile in use" errors after container restarts.
if [ -f "/config/profile/Local State" ]; then
    sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/g' \
        "/config/profile/Local State" 2>/dev/null || true
fi

# vim:ft=sh:ts=4:sw=4:et:sts=4