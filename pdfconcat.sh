#!/usr/bin/env bash

usage() {
    cat 1>&2 <<EOF
Usage: $(basename $0) -o OUTFILE INFILES...
EOF
    exit $1
}

OUTFILE=
INFILES=

while [ $# -ne 0 ]; do
    case $1 in
        -o) shift;
            OUTFILE=$1;;
        -h) usage 0;;
         *) INFILES="$INFILES $1";;
    esac
    shift;
done

if [ "$OUTFILE" = "" ]; then
   usage 1;
fi

gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="$OUTFILE" $INFILES
