#!/bin/bash
# <wtl> project: bootdump | file: uninstall.sh | author: watchthelight </wtl>
# Remove the boot dump daemon: sudo ./uninstall.sh. The dumps themselves stay; delete the output folder by hand.
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
launchctl bootout system/org.watchthelight.bootdump 2>/dev/null
rm -f /Library/LaunchDaemons/org.watchthelight.bootdump.plist
rm -rf "/Library/Application Support/bootdump"
echo "removed; the dumps are still in the output folder (default /Users/Shared/bootdump)"
