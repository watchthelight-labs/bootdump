#!/bin/bash
# <wtl> project: bootdump | file: install.sh | author: watchthelight </wtl>
# Install the boot dump daemon: sudo ./install.sh. It runs once now (dumping the current boot) and at every boot.
# BOOTDUMP_DIR in the environment or in an existing bootdump.conf moves the output folder. Undo: sudo ./uninstall.sh
set -e
cd "$(dirname "$0")"
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
LIB="/Library/Application Support/bootdump"; PLIST=/Library/LaunchDaemons/org.watchthelight.bootdump.plist
mkdir -p "$LIB"
[ -f "$LIB/bootdump.conf" ] && . "$LIB/bootdump.conf"
OUT=${BOOTDUMP_DIR:-/Users/Shared/bootdump}
mkdir -p "$OUT"
install -m 755 -o root -g wheel bootdump.sh "$LIB/bootdump.sh"
install -m 644 -o root -g wheel bootdump.conf.example "$LIB/bootdump.conf.example"
if [ "$OUT" != /Users/Shared/bootdump ] && [ ! -f "$LIB/bootdump.conf" ]; then
  echo "BOOTDUMP_DIR=$OUT" > "$LIB/bootdump.conf"; chown root:wheel "$LIB/bootdump.conf"; chmod 644 "$LIB/bootdump.conf"
fi
install -m 644 -o root -g wheel org.watchthelight.bootdump.plist "$PLIST"
plutil -replace StandardOutPath -string "$OUT/bootdump.out" "$PLIST"
plutil -replace StandardErrorPath -string "$OUT/bootdump.out" "$PLIST"
launchctl bootstrap system "$PLIST" 2>/dev/null || true
echo "installed; the dumps of this boot land in $OUT/"
