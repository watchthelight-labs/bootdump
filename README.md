# bootdump

A LaunchDaemon that takes snapshots of the kernel log, the IORegistry and a few other things at fixed times after every boot, so a boot that never reaches a usable desktop (a black screen, a frozen panel, a hang at login) can still be read afterwards from the next boot or another OS.

I wrote it while bringing up a GPU driver on a Hackintosh, where a bad boot leaves you with a dark panel and no way to type `dmesg`. The defaults reflect that (NVIDIA driver classes and sysctls), but every list is a setting.

## What it captures

At 20, 60, 180 and 300 seconds after boot (20 because the 128 KiB kernel message buffer fills up with network lines soon after), each snapshot `<t>` writes:

| File | Content |
|---|---|
| `dmesg-<t>.txt` | the kernel message buffer |
| `ioreg-<class>-<t>.txt` | `ioreg -l -w0 -r -c <class>` for each class in `BOOTDUMP_IOREG_CLASSES` (default `NVRM NVRMDisplay IOFramebuffer`) |
| `ioreg-<name>-<t>.txt` | `ioreg -l -w0 -r -n <name>` for each entry in `BOOTDUMP_IOREG_NAMES` (default `GFX0`) |
| `sysctl-debug-<t>.txt` | the `sysctl debug` lines matching `BOOTDUMP_SYSCTL_GREP` (default `nv`) |
| `ws-<t>.txt` | whether WindowServer is running (`pgrep -lf WindowServer`) |

Once per boot it also writes `00-info.txt` (boot time, `sw_vers`, `uname -a`, boot-args, SIP status) at the start and `log.txt` (`log show --last boot` with `BOOTDUMP_LOG_PREDICATE`) after the last snapshot.

Each file is flushed with `sync` as soon as it is written, so a hard reset after the 60 s snapshot still leaves the 20 and 60 s files on disk.

## Where the output goes

`/Users/Shared/bootdump/<boot time in UTC>/`, for example `/Users/Shared/bootdump/20261019-172313Z/`. The newest 10 boots are kept, older folders are deleted. The daemon's own output is in `/Users/Shared/bootdump/bootdump.out`.

To read a bad boot, start the next one normally (or from a recovery or older config) and open the folder of the bad boot's time. From Windows or Linux you need something that reads APFS.

## Install

```
git clone https://github.com/watchthelight-labs/bootdump ~/src/bootdump
cd ~/src/bootdump
sudo ./install.sh
```

It copies `bootdump.sh` to `/Library/Application Support/bootdump/`, the LaunchDaemon to `/Library/LaunchDaemons/org.watchthelight.bootdump.plist`, and starts it once, which dumps the current boot. From then on it runs at every boot.

Settings: copy `bootdump.conf.example` to `/Library/Application Support/bootdump/bootdump.conf` and edit it. The script runs as root and reads that file only when root owns it. To move the output folder, set `BOOTDUMP_DIR` there and run `sudo ./install.sh` again (it rewrites the daemon's log path).

Remove: `sudo ./uninstall.sh`. The dumps stay where they are.

## Privacy

The dumps describe your machine in detail. IORegistry output contains display and device serial numbers, PCI and USB ids, and depending on the classes you add, MAC addresses. `dmesg` and the unified log often have MAC addresses, Wi-Fi network names, IP addresses and user names. `/Users/Shared` is readable by every user on the Mac. Look through a dump before you attach it to an issue or a forum post, and cut what you do not want to share.

## Status

In use on a Lenovo Legion 5 15IAX10 Hackintosh (macOS 26.7.1, 25G241) since 2026-10-16, through the bring-up of an NVIDIA GPU driver.

## Licence

ISC, see [LICENSE](LICENSE).
