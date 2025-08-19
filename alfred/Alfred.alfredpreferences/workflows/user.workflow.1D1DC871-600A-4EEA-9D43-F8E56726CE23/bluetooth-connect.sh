#!/usr/bin/env zsh

address="${address_state_and_device_name1}"
state="${address_state_and_device_name2}"
device_name="${address_state_and_device_name3}"

if [[ $state -eq 0 ]]; then
    blueutil --connect "$address"
    echo "Connecting to $address"
elif [[ $state -eq 1 ]]; then
    blueutil --disconnect "$address"
    echo "Disconnecting from $address"
else
    echo "Invalid state: $state (must be 0 or 1)"
    exit 1
fi

SwitchAudioSource -s "$device_name"
SwitchAudioSource -t input -s "$device_name"