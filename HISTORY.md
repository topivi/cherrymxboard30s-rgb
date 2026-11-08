# Session History

## 2026-11-08: Confirm stable use

- The user reported testing and using the software for several weeks without encountering any issues.

## 2026-10-16: Support Cherry keyboard product ID 00dd

- Investigated reports that the application required `sudo` and that the keyboard enumerated as USB `046a:00dd`, rather than the supported `046a:0079`.
- Updated the default USB device search to accept either product ID while keeping explicit `--product-id` selection specific to the requested ID. The USB lighting protocol was not changed.
- Added udev access for `046a:00dd` alongside `046a:0079`; updated manual hardware-test device detection and explicit targeting to use the detected product ID.
- Updated README and Copilot instructions with the supported IDs.
- Validation: CMake build succeeded; all 6 CTest tests passed; the manual test script passed `bash -n` and its target cases listed successfully. Physical keyboard access could not be tested in this environment.
- Committed as `558d5f6` (`Support Cherry keyboard product ID 00dd`) on `copilot/ubuntu-24-26-support`.
- Opened [topivi/cherrymxboard30s-rgb#2](https://github.com/topivi/cherrymxboard30s-rgb/pull/2) in the writable fork. The upstream repository is archived and rejected PR creation.

## 2026-10-16: Publish Ubuntu packages and resolve device access

- Bumped the application version to `0.1.3` and built amd64 Debian packages for Ubuntu 24.04 and 26.04. Both packages include udev rules for `046a:0079` and `046a:00dd`.
- Verified the build and all 6 CTest tests. Built and installed each package in a matching Ubuntu container, checked its version output, and confirmed the 26.04 package included both udev rules.
- Committed and pushed release files to `main` as `325e515` (`Release version 0.1.3`); published [v0.1.3](https://github.com/topivi/cherrymxboard30s-rgb/releases/tag/v0.1.3) with both `.deb` assets. CI passed.
- Explained that apt's unsandboxed-download message for a package under the user's home directory is a notice, and showed copying the file to `/tmp` as an alternative.
- Diagnosed the reported `LIBUSB_ERROR_ACCESS`: the installed udev rule needed reloading and the keyboard reconnecting. The user confirmed hardware tests then worked.
- The user reported creating an issue for the hardware-test report. The upstream repository is archived and the fork's Issues feature was disabled when checked; instructions were provided to enable Issues on the fork and attach the report.
- Latest branch check: clean `main`, synchronized with `origin/main` at `325e515`.
