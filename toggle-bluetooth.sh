#!/bin/bash

WINDOW_ICON=/usr/share/icons/ubuntu-mono-light/status/24/bluetooth-active.svg

send_bluetooth_notification() {
    notify-send -h int:transient:1 -c "device" -u low -a "gnome-control-center" "Bluetooth" "$1" --icon="$WINDOW_ICON"
}

# Make settings open to bluetooth panel
dconf write /org/gnome/control-center/last-panel "'bluetooth'"

if rfkill list bluetooth | grep -q 'yes$' ; then 
    rfkill unblock bluetooth
    send_bluetooth_notification "On"
else
    rfkill block bluetooth
    send_bluetooth_notification "Off"
fi
