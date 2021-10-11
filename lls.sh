#!/usr/bin/env bash

lls_do_color=
if [ -t 1 ]
then lls_do_color="--color=always"
fi

ls -loghAF --group-directories-first --time-style="+%Y-%m-%d %H:%M:%S" $lls_do_color $@ | perl -pe 's/(\S*)(\s+)(\S*)\s(.*)/\4/g'

