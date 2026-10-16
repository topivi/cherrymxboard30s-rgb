# Session History

## 2026-10-16: Support Cherry keyboard product ID 00dd

- Investigated reports that the application required `sudo` and that the keyboard enumerated as USB `046a:00dd`, rather than the supported `046a:0079`.
- Updated the default USB device search to accept either product ID while keeping explicit `--product-id` selection specific to the requested ID. The USB lighting protocol was not changed.
- Added udev access for `046a:00dd` alongside `046a:0079`; updated manual hardware-test device detection and explicit targeting to use the detected product ID.
- Updated README and Copilot instructions with the supported IDs. Noted that the checked-in Ubuntu Debian packages predate the new udev rule.
- Validation: CMake build succeeded; all 6 CTest tests passed; the manual test script passed `bash -n` and its target cases listed successfully. Physical keyboard access could not be tested in this environment.
- Committed as `558d5f6` (`Support Cherry keyboard product ID 00dd`) on `copilot/ubuntu-24-26-support`.
- Opened [topivi/cherrymxboard30s-rgb#2](https://github.com/topivi/cherrymxboard30s-rgb/pull/2) in the writable fork. The upstream repository is archived and rejected PR creation.
