#!/usr/bin/env bash

set -u

program_name=${0##*/}
group=all
executable=${CHERRYMXBOARD30S_RGB:-}
report_path=
list_only=false

usage()
{
    printf 'Usage: %s [--group all|static|modes|random|target|verbose] [--report FILE] [--list] [EXECUTABLE]\n' "$program_name"
    printf '       Set CHERRYMXBOARD30S_RGB to override the installed executable path.\n'
}

while (($# > 0)); do
    case "$1" in
        --group)
            if (($# < 2)); then
                usage >&2
                exit 2
            fi
            group=$2
            shift 2
            ;;
        --report)
            if (($# < 2)); then
                usage >&2
                exit 2
            fi
            report_path=$2
            shift 2
            ;;
        --list)
            list_only=true
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        --*)
            usage >&2
            exit 2
            ;;
        *)
            if [[ -n $executable ]]; then
                printf 'Executable path was supplied more than once.\n' >&2
                usage >&2
                exit 2
            fi
            executable=$1
            shift
            ;;
    esac
done

case "$group" in
    all|static|modes|random|target|verbose) ;;
    *)
        printf 'Unknown test group: %s\n' "$group" >&2
        usage >&2
        exit 2
        ;;
esac

if [[ -z $executable ]]; then
    executable=$(command -v cherrymxboard30s-rgb || true)
fi

if [[ -z $executable || ! -x $executable ]]; then
    printf 'Cannot find an executable cherrymxboard30s-rgb. Install it or pass its path.\n' >&2
    exit 2
fi

declare -a test_names=()
declare -a test_descriptions=()
declare -a test_modes=()
declare -a test_speeds=()
declare -a test_brightnesses=()
declare -a test_colors=()
declare -a test_flags=()

add_test()
{
    test_names+=("$1")
    test_descriptions+=("$2")
    test_modes+=("$3")
    test_speeds+=("$4")
    test_brightnesses+=("$5")
    test_colors+=("$6")
    test_flags+=("$7")
}

if [[ $group == all || $group == static ]]; then
    add_test static-red "Static red, brightness 4" static 4 4 "--red 255 --green 0 --blue 0" ""
    add_test static-green "Static green, brightness 4" static 4 4 "--red 0 --green 255 --blue 0" ""
    add_test static-blue "Static blue, brightness 4" static 4 4 "--red 0 --green 0 --blue 255" ""
    add_test static-mixed-dim "Mixed RGB, brightness 1" static 1 1 "--red 64 --green 128 --blue 192" ""
    add_test static-mixed-bright "Mixed RGB, brightness 4" static 4 4 "--red 64 --green 128 --blue 192" ""
fi

if [[ $group == all || $group == modes ]]; then
    for mode in wave spectrum breathing rolling curve scan radiation ripples single_key; do
        for speed in 0 1 2 3 4; do
            add_test "mode-${mode}-speed-${speed}" "${mode} mode, speed ${speed}" \
                "$mode" "$speed" 4 "--red 64 --green 128 --blue 192" ""
        done
    done
fi

if [[ $group == all || $group == random ]]; then
    add_test wave-explicit-color "Wave mode with explicit color" wave 2 \
        4 "--red 64 --green 128 --blue 192" ""
    add_test wave-random-colors "Wave mode with random colors" wave 2 \
        4 "--red 64 --green 128 --blue 192" "-r"
fi

if [[ $group == all || $group == target ]]; then
    add_test target-default "Target the default Cherry USB device" static 4 \
        4 "--red 64 --green 128 --blue 192" ""
    add_test target-explicit "Target USB vendor 0x046a and product 0x0079" static 4 \
        4 "--red 64 --green 128 --blue 192" ""
fi

if [[ $group == all || $group == verbose ]]; then
    add_test verbose-output "Static mode with verbose libusb logging" static 4 \
        4 "--red 64 --green 128 --blue 192" ""
fi

if [[ $list_only == true ]]; then
    printf 'Test group: %s\nExecutable: %s\n' "$group" "$executable"
    for index in "${!test_names[@]}"; do
        printf '%-30s %s\n' "${test_names[index]}" "${test_descriptions[index]}"
    done
    exit 0
fi

if [[ ! -t 0 ]]; then
    printf 'This hardware test requires an interactive terminal.\n' >&2
    exit 2
fi

if ((EUID == 0)); then
    printf 'Run this test as your normal user, not with sudo.\n' >&2
    exit 2
fi

declare -a matching_devices=()
shopt -s nullglob
for device_path in /sys/bus/usb/devices/*; do
    [[ -r $device_path/idVendor && -r $device_path/idProduct ]] || continue
    read -r vendor_id < "$device_path/idVendor"
    read -r product_id < "$device_path/idProduct"
    if [[ ${vendor_id,,} == 046a && ${product_id,,} == 0079 ]]; then
        matching_devices+=("$device_path")
    fi
done
shopt -u nullglob

if ((${#matching_devices[@]} == 0)); then
    printf 'No USB device with vendor/product ID 046a:0079 was found. Connect the keyboard and retry.\n' >&2
    exit 2
fi

if [[ -z $report_path ]]; then
    report_path="$PWD/hardware-test-report-$(date -u +%Y%m%dT%H%M%SZ).txt"
fi

if [[ -e $report_path ]]; then
    printf 'Report already exists; refusing to overwrite: %s\n' "$report_path" >&2
    exit 2
fi

umask 077
set -o noclobber
if ! : > "$report_path"; then
    printf 'Could not create report file: %s\n' "$report_path" >&2
    exit 2
fi
set +o noclobber

{
    printf 'Cherry MX Board 3.0 S hardware test report\n'
    printf 'Started (UTC): %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'Executable: %s\n' "$executable"
    printf 'Test group: %s\n' "$group"
    printf 'User: %s (uid %s)\n' "$(id -un)" "$(id -u)"
    if [[ -r /etc/os-release ]]; then
        . /etc/os-release
        printf 'Operating system: %s\n' "${PRETTY_NAME:-unknown}"
    fi
    for device_path in "${matching_devices[@]}"; do
        printf 'USB device: %s (046a:0079)\n' "$device_path"
    done
    printf '\nResults:\n'
} >> "$report_path"

printf 'Hardware test group: %s\n' "$group"
printf 'Executable: %s\n' "$executable"
printf 'Running as: %s (uid %s)\n' "$(id -un)" "$(id -u)"
printf 'Keyboard found: %s\n' "${matching_devices[*]}"
printf 'Report: %s\n' "$report_path"
printf 'Connect the keyboard directly if possible. Commands run as the current user; do not run this script with sudo.\n'
printf 'Each case sends a lighting command. Inspect the keyboard and answer [p]ass, [f]ail, [s]kip, or [q]uit.\n\n'

passed=0
failed=0
skipped=0
interrupted=false

for index in "${!test_names[@]}"; do
    name=${test_names[index]}
    description=${test_descriptions[index]}
    mode=${test_modes[index]}
    speed=${test_speeds[index]}
    brightness=${test_brightnesses[index]}
    color_words=${test_colors[index]}
    flag_words=${test_flags[index]}
    read -r -a color_args <<< "$color_words"
    read -r -a flag_args <<< "$flag_words"
    command_args=(-l "$mode")
    if [[ $mode != static ]]; then
        command_args+=(-s "$speed")
    fi
    command_args+=(-b "$brightness" "${color_args[@]}" "${flag_args[@]}")

    case "$name" in
        target-explicit)
            command_args+=(--vendor-id 0x046a --product-id 0x0079)
            ;;
        verbose-output)
            command_args+=(-v)
            ;;
    esac

    printf '[%d/%d] %s: %s\n' "$((index + 1))" "${#test_names[@]}" "$name" "$description"
    printf 'Command:'
    printf ' %q' "$executable" "${command_args[@]}"
    printf '\n'

    exit_code=0
    "$executable" "${command_args[@]}" || exit_code=$?
    if ((exit_code != 0)); then
        printf 'Program exited with status %d.\n' "$exit_code"
    fi

    while true; do
        printf 'Result [p/f/s/q]: '
        if ! read -r result; then
            result=q
        fi
        case "$result" in
            p|f|s|q) break ;;
            *) printf 'Enter p, f, s, or q.\n' ;;
        esac
    done

    case "$result" in
        p)
            if ((exit_code == 0)); then
                outcome=PASS
                ((passed += 1))
            else
                outcome=FAIL
                ((failed += 1))
            fi
            ;;
        f)
            outcome=FAIL
            ((failed += 1))
            ;;
        s)
            outcome=SKIP
            ((skipped += 1))
            ;;
        q)
            outcome=SKIP
            ((skipped += 1))
            interrupted=true
            ;;
    esac

    printf '%s\t%s\tprocess_exit=%d\t%s\n' "$outcome" "$name" "$exit_code" "$description" >> "$report_path"
    printf 'Recorded: %s\n\n' "$outcome"
    if [[ $interrupted == true ]]; then
        break
    fi
done

if [[ $interrupted == true ]]; then
    for ((remaining = index + 1; remaining < ${#test_names[@]}; remaining++)); do
        printf 'SKIP\t%s\tprocess_exit=not-run\t%s\n' \
            "${test_names[remaining]}" "${test_descriptions[remaining]}" >> "$report_path"
        ((skipped += 1))
    done
fi

{
    printf '\nSummary: passed=%d failed=%d skipped=%d\n' "$passed" "$failed" "$skipped"
    printf 'Finished (UTC): %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} >> "$report_path"

printf 'Summary: passed=%d failed=%d skipped=%d\n' "$passed" "$failed" "$skipped"
printf 'Report saved to %s\n' "$report_path"

if ((failed > 0)); then
    exit 1
fi
