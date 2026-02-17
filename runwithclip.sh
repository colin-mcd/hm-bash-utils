#!/usr/bin/env bash

MYCLIP=$(realpath -q "$(eval echo $(wl-paste))")

if [ -e "$MYCLIP" ]; then
    $1 $MYCLIP
else
    ${2:-$1}
fi

