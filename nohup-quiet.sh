#!/usr/bin/env bash
nohup $1 ${@:2} > /dev/null 2>&1 &
