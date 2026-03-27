#!/usr/bin/env bash

usage() {
    cat 1>&2 <<EOF
Usage: $(basename $0) [on|off|toggle]
Enables/disables hyperthreading (SMT) system-wide.
EOF
    exit $1
}

enable_smt() {
    echo -n "Enabling hyperthreading (SMT)... "
    echo on | sudo tee /sys/devices/system/cpu/smt/control
}

disable_smt() {
    echo -n "Disabling hyperthreading (SMT)... "
    echo off | sudo tee /sys/devices/system/cpu/smt/control
}

toggle_smt() {
    SMT_BEFORE=$(cat /sys/devices/system/cpu/smt/active)
    if [ $SMT_BEFORE -eq 1 ];
    then
        disable_smt
    else
        enable_smt
    fi
}

if [ $# -eq 1 ]; then
    case $1 in
        on) enable_smt;;
        off) disable_smt;;
        toggle) toggle_smt;;
        help) usage 0;;
        *) usage 1 ;;
    esac
elif [ $# -eq 0 ]; then
    toggle_smt
else
    usage 1
fi


