# Copilot instructions

## Build, test, and lint

The project uses CMake and requires `libusb-1.0` development files (including `pkg-config` metadata).

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

The executable is `build/cherrymxboard30s-rgb`. For the CI-equivalent Make build, run `make -C build`. Installation is `sudo cmake --install build`; this installs the executable and udev rule under system paths and reloads/triggers udev.

CTest includes hardware-independent CLI smoke tests and unit tests for argument initialization/parsing and lighting defaults/mode names. Run all registered tests with:

```sh
ctest --test-dir build --output-on-failure
```

Run one registered test by name with:

```sh
ctest --test-dir build -R '<test-name>' --output-on-failure
```

Manual keyboard acceptance tests live in `tests/manual/hardware_test.sh`. They require the physical `046a:0079` device and an interactive terminal; run them as a regular user, not with `sudo`.

There is no configured lint target or lint command. The current compiler warning option is `-Wall`.

## Architecture

This is a command-line C application that sends lighting commands to the Cherry MX Board 3.0 S over USB using libusb.

- `src/main.c` initializes and parses `args_t`, then delegates the operation to `device_set_lighting`.
- `src/args/` owns CLI parsing and defaults. Parsed values are copied into the device-facing `lighting_t` in `src/device/device.c`.
- `src/device/device.c` initializes libusb, finds the keyboard by vendor/product ID (defaults are declared in `device.h`), claims its interfaces, chooses the lighting-mode handler, sends the USB control transfer, and releases resources.
- Each mode handler builds the keyboard's protocol payload; `src/device/lighting.c` initializes the shared lighting structure and maps modes to display names.
- `src/help/` formats usage/version output; `src/log/` provides timestamped info, debug, and error output.
- `50-cherrymx.rules` grants access to USB device `046a:0079`. The CMake install also places this rule in `/etc/udev/rules.d` and reloads udev.

## Codebase conventions

- Keep C declarations and implementations in the matching module directory (`*.h` / `*.c`), and use module-prefixed functions such as `device_*` and `args_*`.
- Shared application state is passed through `args_t` and `lighting_t`; keep CLI parsing/defaults distinct from USB device/protocol handling.
- Lighting modes are wired across several places: the `LMODE` enum in `src/device/lighting.h`, string parsing in `src/args/args.c`, display names in `src/device/lighting.c`, dispatch and packet handling in `src/device/device.c`, and the mode list in `src/help/help.c`. Keep these in sync when adding or changing a mode.
- USB mode payloads are device-specific reverse-engineered protocol data. Preserve existing bytes and control-transfer parameters unless the protocol change is intentional and grounded in device behavior; the README warns that incorrect communication may affect the keyboard.
- CMake is the source of build configuration and includes source registration, the `VERSION`/`PROJECT_URL` compile definitions, libusb linkage, and install/package configuration.
