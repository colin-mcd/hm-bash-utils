#!/usr/bin/env bash

MYCLIP=$(realpath -q "$(xclip -o -selection c)")

if [ -e "$MYCLIP" ]; then
    $1 $MYCLIP
else
    ${2:-$1}
fi

