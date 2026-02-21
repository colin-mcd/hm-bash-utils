#!/usr/bin/env bash

nohup $1 ${@:2} > /dev/null &
