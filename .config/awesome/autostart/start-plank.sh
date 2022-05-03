#!/bin/bash

ACTIVE_MONITORS=$(xrandr --listactivemonitors | grep -P '^\s*\d:' | awk '{print $NF}' | tr '\n' ' ')

for each_monitor in ${ACTIVE_MONITORS[*]};do
    exec plank -n ${each_monitor} 1>/dev/null 2>&1 &
done
