#!/usr/bin/env bash

# credit goes to https://stackoverflow.com/a/14435749
gs -q -dNOPAUSE -dBATCH -dPDFSETTINGS=/prepress -sDEVICE=pdfwrite -sOutputFile="$2" "$1"
