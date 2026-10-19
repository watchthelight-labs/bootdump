# Contributing

The most useful thing is a set of settings that worked for you on other hardware: which IORegistry classes, sysctls and log predicate told you what a bad boot did, for an Intel or AMD GPU, Wi-Fi or USB. Open an issue with the machine, the macOS build and your `bootdump.conf`. If the daemon missed a snapshot or the folder was empty after a hang, include `bootdump.out` and the file list of that boot's folder. Please do not paste whole dumps; see the privacy note in the README.

Pull requests: keep them small and say how you tested them. AI-assisted PRs are fine as long as you can explain the change, which is the same bar I hold my own code to.
