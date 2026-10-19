# Changelog

## 0.1.0 (2026-10-19)

- First public version of the boot dump daemon used on the Legion 5 15IAX10 Hackintosh since 2026-10-16.
- Settings file (`bootdump.conf`, read only when root owns it) for the output folder, boots to keep, snapshot times, IORegistry classes and names, sysctl filter and log predicate. The defaults are the values the original used.
- Output in `/Users/Shared/bootdump/`; file names follow the class names (`ioreg-ioframebuffer-<t>.txt`, `sysctl-debug-<t>.txt`, `log.txt`).
- `uninstall.sh`.
