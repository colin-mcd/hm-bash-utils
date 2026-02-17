#!/usr/bin/env bash

# On a new system:
# Install kmonad: https://github.com/kmonad/kmonad/blob/master/doc/installation.md
# Then, run the following commands
# $ sudo groupadd uinput
# $ sudo usermod -Ag input,uinput YOUR-USERNAME
# $ sudo echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' > /etc/udev/rules.d/kmonad-input.rules
# $ sudo modprobe uinput
# Then reboot
# Next, install the KMonad Toggle gnome extension: https://github.com/jurf/gnome-kmonad-toggle
# (You can determine your gnome shell version with `$ gnome-shell --version`
#  and then just select the most recent version of the extension)
# Then go to extension manager, and type this file's location as the custom command

# List of device names to use kmonad on (can be regular expressions)
DEVICE_NAMES=('AT Translated Set 2 keyboard' 'Air75 BT5.0 ')

SCRIPT_PATH=$(realpath "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd -- "$( dirname -- "${SCRIPT_PATH}" )" &> /dev/null && pwd)

#DEVICES="/dev/input/by-id/usb-BY_Tech_Air75-event-kbd /dev/input/by-path/platform-i8042-serio-0-event-kbd"
# Fetch all keyboard devices, expand symlinks, and deduplicate
#DEVICES=$(for fp in /dev/input/by-path/*-kbd; do realpath $fp; done | tr " " "\n" | sort -u)
DEVICES=$(cat /proc/bus/input/devices | tr '\n' '\t' | sed -Ee 's/\t\t/\n/g' | tr '\t' '#')

DEVICES_FILTERED=()
while IFS= read -r deviceinfo || [[ -n "$deviceinfo" ]]; do
  DNAME=$(echo $deviceinfo | egrep -o 'Name="[^#]*"#' | sed -Ee 's/Name="(.*)"#/\1/g')
  EVENT=$(echo $deviceinfo | egrep -o 'Handlers=[^#]* event[0-9]+' | sed -Ee 's/.*(event[0-9]+)/\1/g')
  for NAME in "${DEVICE_NAMES[@]}"; do
    if echo "$DNAME" | grep -q "$NAME"; then
        DEVICES_FILTERED+=("/dev/input/$EVENT")
    fi
  done
done < <(printf "%s" "$DEVICES")

function handler() {
    # if you ever need to find the kmonad procs,
    # run `systemctl status` and look near the end
    # under org.gnome.Shell@wayland.service,
    # then kill those pids
    pkill -P $$
}

function runkmonad() {
    KEYBOARD=$1
    export KEYBOARD
    kmonad <(cat "$SCRIPT_DIR/kmonad.kbd" | envsubst) &
    while true; do
        sleep 1;
        
    done
}

trap handler EXIT

for KEYBOARD in ${DEVICES_FILTERED[@]}; do
    echo "$KEYBOARD"
    if [[ -e "$KEYBOARD" ]]; then
        export KEYBOARD
        $SCRIPT_DIR/pr_set_pdeathsig 9 kmonad <(cat "$SCRIPT_DIR/kmonad.kbd" | envsubst) &
    fi
done

wait
