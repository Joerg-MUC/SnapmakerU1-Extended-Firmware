# joergmuc mod

Personal mod, not part of the maintained `firmware-extended` build.

## 01-dev-overlay

Gives the image its own overlay directory (`/oem/overlay-dev` instead of `/oem/overlay`).

Why: the writable overlay of the stock init is bound to the image it was created over. On a
printer with a stable image in one A/B slot and a second image in the other slot, mounting the
overlay of one image over the other fails (`overlayfs: failed to verify upper root origin`), the
system runs without overlay and services such as the MQTT broker do not start. With an own
overlay directory per image both slots can be switched with `updateEngine --misc=other` and a
reboot, and the overlay of the other slot is never touched.

What the replacement `S01aoverlayfs` does:

- rebuilds `/oem/overlay-dev` whenever the image changes (stamp `/oem/overlay-dev/.image-id` from
  `/etc/BUILD_VERSION` and its mtime) or when `/oem/.debug` is missing (like the stock init)
- after a rebuild, seeds a short list of files from the overlay of the other slot
  (`/oem/overlay/upper`): SSH host key, `authorized_keys` for `root` and `lava`, Wi-Fi
  configuration, time zone. Everything else starts from the image defaults.
- ships the Wi-Fi restore hook `/etc/hooks/lmd.d/05-wifi-restore.sh` in the image. It restores
  `/etc/wpa_supplicant.conf` from the GUI copy in `/oem/printer_data/gui/` (shared by both slots)
  when the overlay has none, so Wi-Fi comes back even without seeding.
- retries once with a fresh directory when the overlay mount fails

The build fails if the stock `S01aoverlayfs` changes (checksum guard in `pre-scripts/`).

Build: `./dev.sh make build PROFILE=extended-joergmuc OUTPUT_FILE=firmware/U1_extended.bin`

Switching slots on the printer (as `root`, no print running): `updateEngine --misc=other`, check
with `updateEngine --misc=display` that the target slot has the higher priority, then `reboot`.
