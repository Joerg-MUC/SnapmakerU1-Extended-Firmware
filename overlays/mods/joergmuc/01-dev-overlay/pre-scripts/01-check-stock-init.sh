#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Guard for the S01aoverlayfs replacement in ../root/etc/init.d/S01aoverlayfs.
# The replacement is a full copy of the stock script with an own overlay directory,
# so it has to be reviewed when Snapmaker changes the stock script. Fail the build
# loudly instead of silently shipping an outdated init script.

set -euo pipefail

ROOTFS_DIR="$1"
INIT="$ROOTFS_DIR/etc/init.d/S01aoverlayfs"
EXPECTED=d304fd417ff29cad413d9a3944d909758fbd7a065436708f0ce136c1499b32b5

actual=$(sha256sum "$INIT" | cut -d' ' -f1)
if [[ "$actual" != "$EXPECTED" ]]; then
    echo "!! The stock S01aoverlayfs changed (sha256 $actual, expected $EXPECTED)."
    echo "!! Review the change and update overlays/mods/joergmuc/01-dev-overlay/root/etc/init.d/S01aoverlayfs and the checksum here."
    exit 1
fi
echo "stock S01aoverlayfs matches the version the replacement is based on"
