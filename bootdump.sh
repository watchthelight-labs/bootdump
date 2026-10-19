#!/bin/bash
# <wtl> project: bootdump | file: bootdump.sh | author: watchthelight </wtl>
# Runs as root at every boot (LaunchDaemon org.watchthelight.bootdump). Saves the kernel message buffer, chosen
# IORegistry classes and sysctls and the WindowServer process at 20, 60, 180 and 300 s after boot (20 s because the
# 128 KiB kernel buffer fills with network lines) into $BOOTDUMP_DIR/<boot time>/, so a boot that never reaches the
# desktop can be read afterwards from another boot or OS. Read-only on the system; it only writes its own folder and
# keeps the newest $BOOTDUMP_KEEP boots.
# Settings: /Library/Application Support/bootdump/bootdump.conf (see bootdump.conf.example), read only when owned by root.
set -u
CONF=${BOOTDUMP_CONF:-/Library/Application Support/bootdump/bootdump.conf}
[ -f "$CONF" ] && [ "$(stat -f %u "$CONF")" = 0 ] && . "$CONF"
OUT=${BOOTDUMP_DIR:-/Users/Shared/bootdump}
KEEP=${BOOTDUMP_KEEP:-10}
TIMES=${BOOTDUMP_TIMES:-20 60 180 300}
CLASSES=${BOOTDUMP_IOREG_CLASSES-NVRM NVRMDisplay IOFramebuffer}
NAMES=${BOOTDUMP_IOREG_NAMES-GFX0}
SYSCTL=${BOOTDUMP_SYSCTL_GREP-nv}
PRED=${BOOTDUMP_LOG_PREDICATE-sender CONTAINS[c] "NV" OR eventMessage CONTAINS "NVRM"}
BOOT=$(sysctl -n kern.boottime | sed -E 's/^\{ sec = ([0-9]+),.*/\1/')
D="$OUT/$(date -u -r "$BOOT" +%Y%m%d-%H%M%SZ)"
mkdir -p "$D"
{ echo "boot $(date -u -r "$BOOT")"; sw_vers; uname -a; sysctl -n kern.bootargs; csrutil status 2>&1; } > "$D/00-info.txt"
for t in $TIMES; do
  now=$(date +%s); wait=$((BOOT + t - now)); [ "$wait" -gt 0 ] && sleep "$wait"
  dmesg > "$D/dmesg-$t.txt" 2>&1
  for c in $CLASSES; do ioreg -l -w0 -r -c "$c" > "$D/ioreg-$(echo "$c" | tr '[:upper:]' '[:lower:]')-$t.txt" 2>&1; done
  for n in $NAMES; do ioreg -l -w0 -r -n "$n" > "$D/ioreg-$(echo "$n" | tr '[:upper:]' '[:lower:]')-$t.txt" 2>&1; done
  [ -n "$SYSCTL" ] && sysctl debug 2>/dev/null | grep -i "$SYSCTL" > "$D/sysctl-debug-$t.txt"
  pgrep -lf WindowServer > "$D/ws-$t.txt" 2>&1
  sync
done
[ -n "$PRED" ] && log show --last boot --style compact --predicate "$PRED" > "$D/log.txt" 2>&1
sync
ls -1dt "$OUT"/*/ 2>/dev/null | tail -n +$((KEEP + 1)) | while read -r old; do rm -r "$old"; done
