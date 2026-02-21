#!/usr/bin/env bash

usage() {
    cat 1>&2 <<EOF
Usage: $(basename $0) OPTIONAL_FLAG...
OPTIONAL_FLAG customizes the output format:
  --rgb		255 128 64
  --hex		ff8040
  --fp[=n]	floating point with n digits of precision (e.g. --fp=3 => 0.100 0.244 0.810)
EOF
    exit $1
}

COLOR_FORMAT="hex"
FP_PRECISION=6
COPY_OR_STDOUT="stdout"

while [ $# -gt 0 ]; do
    case $1 in
        --hex|--rgb|--fp) COLOR_FORMAT=$(echo $1 | cut -c 3-);;
        --fp=*) COLOR_FORMAT="fp"; FP_PRECISION=$(echo $1 | cut -c 6-);;
        --copy) COPY_OR_STDOUT="copy";;
        --stdout) COPY_OR_STDOUT="stdout";;
        -h | --help) usage 0;;
         *) usage 1;;
    esac;
    shift
done

set -e

# from https://unix.stackexchange.com/a/724963
colormsg=$(gdbus call --session --dest org.gnome.Shell.Screenshot --object-path /org/gnome/Shell/Screenshot --method org.gnome.Shell.Screenshot.PickColor)
##drop first 13 and last 5 characters: ({'color': <(...)>},)
#colormsg=${colormsg:13:-5}
colors=($(echo $colormsg | command grep -o "[0-9\.]*"))

SPACING=" "

# Convert to 255-based RGB format
for ((i = 0; i < ${#colors[@]}; i++)); do
    case "$COLOR_FORMAT" in
        rgb) colors[$i]=$(printf '%.0f' $(echo "${colors[$i]} * 255" | bc));;
        hex) colors[$i]=$(printf '%02X' $(printf '%.0f' $(echo "${colors[$i]} * 255" | bc)));
             SPACING="";; # no spaces between R, G, B fields
        fp)  colors[$i]=$(printf "%.0${FP_PRECISION}f" "${colors[$i]}");;
    esac
done

if [[ "$COPY_OR_STDOUT" == "copy" ]]; then
    echo -n "${colors[0]}${SPACING}${colors[1]}${SPACING}${colors[2]}" | wl-copy
elif [[ "$COPY_OR_STDOUT" == "stdout" ]]; then
    echo -n "${colors[0]}${SPACING}${colors[1]}${SPACING}${colors[2]}" | ydotool type --file -
else
    usage 1
fi
# echo   "RGB: ${colors[0]} ${colors[1]} ${colors[2]}"
# printf "HEX: %02x%02x%02x\n" "${colors[0]}" "${colors[1]}" "${colors[2]}"
#echo "$colors"
