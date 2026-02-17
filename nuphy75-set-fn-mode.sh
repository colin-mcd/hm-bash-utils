#!/usr/bin/env bash

# https://www.reddit.com/r/MechanicalKeyboards/comments/tgjvp2/nuphy_air75_on_linux_issues_with_fn/

echo 'options hid_apple fnmode=0' | \
    sudo tee -a /etc/modprobe.d/hid_apple.conf
