#!/usr/bin/env zsh

set -e

# Ensure tools are in PATH for Alfred execution
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
function printIt() {
    local msg="$1"
    local ts
    if [[ -n "${EPOCHREALTIME:-}" ]]; then
        local ereal="$EPOCHREALTIME"         # e.g., 1693231234.123456
        local esec="${ereal%%.*}"            # seconds since epoch
        local emicro="${ereal#*.}"           # microseconds (6 digits)
        local ems
        ems=$(printf '%.3s' "$emicro")       # first 3 digits = milliseconds
        ts="$(date -r "$esec" '+%Y-%m-%d %H:%M:%S').$ems"
    else
        ts="$(date '+%Y-%m-%d %H:%M:%S').000"
    fi

    echo "$msg"
    echo "$ts $msg" >> bluetooth-connect.log
}

printIt "Start script"
WAIT_SECS=5
address="${address_state_and_device_name1}"
state="${address_state_and_device_name2}"
device_name="${address_state_and_device_name3}"
printIt "Address: $address | State: $state | Device Name: $device_name"

case "$state" in
    0)
        printIt "Connecting to $address"
        if blueutil --connect "$address"; then
            if blueutil --wait-connect "$address" "$WAIT_SECS"; then
                printIt "Connected to $address"
            else
                printIt "Failed to confirm connection to $address within ${WAIT_SECS}s"
                exit 3
            fi
        else
            printIt "Failed to initiate connection to $address"
            exit 2
        fi

        printIt "Attempting to Switch Audio Source to $device_name"
        if ! SwitchAudioSource -t all -s "$device_name"; then
            printIt "Failed to switch audio to $device_name"
            exit 4
        fi
        ;;
    1)
        printIt "Disconnecting from $address"
        if ! blueutil --is-connected "$address"; then
            printIt "Already disconnected: $address"
            exit 0
        fi

        if blueutil --disconnect "$address" && blueutil --wait-disconnect "$address" "$WAIT_SECS"; then
            printIt "Disconnected from $address"
        else
            if blueutil --is-connected "$address"; then
                printIt "Failed to disconnect $address within ${WAIT_SECS}s"
                exit 1
            else
                printIt "Disconnected from $address"
            fi
        fi
        ;;
    *)
        printIt "Invalid state: $state (must be 0 or 1)"
        exit 1
        ;;
esac

printIt "End script"
