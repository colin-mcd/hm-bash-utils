#!/usr/bin/env bash

SCHEMA=org.gnome.desktop.a11y.keyboard

# Enable mouse keys (move mouse using numpad)
gsettings set $SCHEMA mousekeys-enable true
gsettings set $SCHEMA mousekeys-max-speed 3000
gsettings set $SCHEMA mousekeys-accel-time 3000
gsettings set $SCHEMA mousekeys-init-delay 0
