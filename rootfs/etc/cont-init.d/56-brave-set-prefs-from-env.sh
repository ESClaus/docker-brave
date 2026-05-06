#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Make sure the Brave profile directory exists.
mkdir -p /config/profile/Default

# vim:ft=sh:ts=4:sw=4:et:sts=4