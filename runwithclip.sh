#!/usr/bin/env bash

MYCLIP=`xclip -o -selection c`

if [ -a "$MYCLIP" ]; then
    $1 $MYCLIP
else
    ${2:-$1}
fi

