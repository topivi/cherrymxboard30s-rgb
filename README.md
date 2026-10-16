# CherryMXBoard30s RGB

[![Ubuntu 22.04, 24.04 & 26.04 Build](https://github.com/luv4bytes/cherrymxboard30s-rgb/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/luv4bytes/cherrymxboard30s-rgb/actions/workflows/ubuntu.yml)

Please consider using [cherryrgb-rs](https://github.com/skraus-dev/cherryrgb-rs) by @skraus-dev ([Sebastian Kraus](https://github.com/skraus-dev)) for a more robust and versatile solution.

Software for controlling RGB lighting on the *Cherry MX Board 3.0 S*    for Linux.

![](doc/img/cherrymx30s_demo.gif)

I reverse engineered the USB packets that are sent to the keyboard by the official Cherry Utility software which is only available for Windows. So there is always a chance that this program might brick your device because of missing or wrong interpreted communications. So far the implemented lighting modes and effects seem to work.

### <span style="color:red">***Use at own risk***</span>

*This project is still WIP. Not every effect is implemented yet.*

Currently missing:

- Custom

### Ubuntu compatibility

CI is configured to build and run CLI smoke tests on Ubuntu 22.04, 24.04, and 26.04. This does not verify USB communication with a physical keyboard on those releases.

Hardware testing has been performed on Ubuntu 20.04, 21.10, and 22.04.

### Prebuilt Ubuntu packages

Release-mode amd64 Debian packages for Ubuntu 24.04 and 26.04 are attached to the GitHub `v0.1.3` release and included under `dist/` in the source tree. Install the matching package with:

```sh
sudo apt install ./dist/ubuntu-24.04/cherrymxboard30s-rgb_0.1.3-1_amd64-ubuntu24.04.deb
```

For Ubuntu 26.04, use `sudo apt install ./dist/ubuntu-26.04/cherrymxboard30s-rgb_0.1.3-1_amd64-ubuntu26.04.deb`. The packages include udev rules for product IDs `046a:0079` and `046a:00dd` and declare their runtime dependencies; install with `apt` so dependencies are resolved. USB lighting behavior has not been validated with physical keyboard hardware.

## Build & Install

### Build requirements

- CMake 3.5 or newer
- A C compiler and Make (`build-essential` on Ubuntu)
- `pkg-config`
- `libusb-1.0-0-dev`

On Ubuntu, install the dependencies with:

```sh
sudo apt-get install build-essential cmake pkg-config libusb-1.0-0-dev
```

Configure and build:

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

Install with:

```sh
sudo cmake --install build
```

Run the CLI smoke tests and unit tests with:

```sh
ctest --test-dir build --output-on-failure
```

To run one test, pass its name as a regular expression, for example:

```sh
ctest --test-dir build -R '^args-parse-and-clamp$' --output-on-failure
```

### Manual hardware tests

After installing the program and connecting the keyboard, run the interactive hardware test set as your normal user (not with `sudo`):

```sh
tests/manual/hardware_test.sh
```

It prompts for visual confirmation after each lighting command and writes a timestamped report in the current directory. The full run checks static colors and brightness, all implemented dynamic modes at speeds 0 through 4, random versus explicit wave colors, default and explicit USB IDs, and verbose mode. `custom` is excluded because its handler is not implemented. The last command's lighting remains active until changed again.

The default device search supports product IDs `046a:0079` and `046a:00dd`; explicit `--product-id` selection still targets only the requested product. The udev rules grant access to both IDs. After installing or changing the rules, reconnect the keyboard before running without `sudo`.

Use `--group static`, `--group modes`, `--group random`, `--group target`, or `--group verbose` to run a subset. List the cases without sending USB commands with `tests/manual/hardware_test.sh --list`; pass the installed executable path as the final argument if it is not on `PATH`. Use `--report FILE` to choose a report path. The script checks that either supported USB device (`046a:0079` or `046a:00dd`) is connected and its explicit-ID case targets the detected product, but every case still requires visual confirmation.

## Usage

To display the program help you need to run the program without any further arguments.

```
./cherrymxboard30s-rgb
```

### Examples

```
# Setting the keyboard to static red light with full brightness.

./cherrymxboard30s-rgb -l static --red 255 -b 4


# Setting the keybord to wave light with random colors and full speed.

./cherrymxboard30s-rgb -l wave -r -b 4 -s 0


# Setting keyboard device and vendor id.

./cherrymxboard30-rgb -l static --blue 255 --vendor-id 0x0001 --product-id 0x0002
```
