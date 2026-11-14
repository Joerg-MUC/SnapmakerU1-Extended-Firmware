# SPDX-License-Identifier: GPL-3.0-or-later
# Restore the WLAN config from the GUI copy before lmd/GUI starts wpa_supplicant.
# Sourced by S90lmd. Acts on "start" only. Lives here instead of /etc/init.d because
# rcS expands its S??* glob before the overlay is mounted (overlay-only init scripts never run).
if [ "$1" = start ]; then
    (
        G=/oem/printer_data/gui/wpa_supplicant.conf
        E=/etc/wpa_supplicant.conf
        L=/oem/wifi-restore.log
        has_net() { [ -r "$1" ] && grep -q '^[[:space:]]*network=' "$1"; }
        if has_net "$E"; then
            r="etc-ok"
        elif has_net "$G"; then
            if cp "$G" "$E"; then r="restored-from-gui"; else r="restore-failed"; fi
        else
            r="no-source"
        fi
        echo "$(date '+%F %T') up=$(cut -d' ' -f1 /proc/uptime)s result=$r etc=$(wc -c < "$E" 2>/dev/null) gui=$(wc -c < "$G" 2>/dev/null)" >> "$L"
        tail -n 100 "$L" > "$L.tmp" && mv "$L.tmp" "$L"
    )
fi
