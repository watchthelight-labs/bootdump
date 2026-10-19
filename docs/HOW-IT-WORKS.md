# How bootdump works

## Start and timing

The LaunchDaemon has `RunAtLoad` and no `KeepAlive`, so launchd starts `bootdump.sh` once per boot as root, early, before anyone logs in. The script reads the boot time from `sysctl -n kern.boottime` and works out each snapshot from it: for a snapshot at `t` seconds it sleeps `boot + t - now` seconds, or not at all when that time has already passed. A daemon that started late still takes every snapshot, the early ones just come later than asked.

The folder name is the boot time in UTC (`date -u -r <boot> +%Y%m%d-%H%M%SZ`), so a bad boot can be found later by its time, and a second run during the same boot (the installer, or `launchctl kickstart`) writes into the same folder and overwrites the files with newer ones.

## Why these times

- 20 s: the kernel message buffer is 128 KiB. On a laptop with Wi-Fi it fills with network lines within a minute or two, and early driver messages scroll out. 20 s is usually after the GPU driver has started and before the buffer wraps.
- 60 s: around the login window, when WindowServer has taken over the display.
- 180 s and 300 s: after login, for problems that show up once the desktop is in use.

Change them with `BOOTDUMP_TIMES`.

## Surviving a hard reset

A hang often ends with the power button. The script runs `sync` after each snapshot, so everything up to the last finished snapshot is on disk. `log.txt` comes last because `log show --last boot` reads the whole boot's log and can take a while.

## Settings

`/Library/Application Support/bootdump/bootdump.conf` is sourced by a root shell, so the script reads it only when its owner is root (`stat -f %u`). Without the file, the defaults in `bootdump.sh` apply; `bootdump.conf.example` lists them. An empty `BOOTDUMP_IOREG_CLASSES`, `BOOTDUMP_IOREG_NAMES`, `BOOTDUMP_SYSCTL_GREP` or `BOOTDUMP_LOG_PREDICATE` turns that part off.

LaunchDaemon plists cannot expand variables, so `install.sh` writes the output folder into the plist's `StandardOutPath` and `StandardErrorPath` with `plutil -replace`.

## Cleanup

After the last snapshot it lists the boot folders newest first (`ls -1dt`) and deletes everything after the first `BOOTDUMP_KEEP` (default 10). It touches nothing outside its output folder.
