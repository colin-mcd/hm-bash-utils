#!/usr/bin/env bash

# Install the KMonad Toggle gnome extension: https://github.com/jurf/gnome-kmonad-toggle
# Then go to extension manager, and type this file's location as the custom command

SCRIPT_PATH=$(realpath "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd -- "$( dirname -- "${SCRIPT_PATH}" )" &> /dev/null && pwd)

DEVICES="/dev/input/by-id/usb-BY_Tech_Air75-event-kbd /dev/input/by-path/platform-i8042-serio-0-event-kbd"

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

for KEYBOARD in $DEVICES; do
    if [[ -e "$KEYBOARD" ]]; then
        export KEYBOARD
        $SCRIPT_DIR/pr_set_pdeathsig 9 kmonad <(cat "$SCRIPT_DIR/kmonad.kbd" | envsubst) &
    fi
done

wait
