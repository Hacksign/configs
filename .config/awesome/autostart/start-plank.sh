#!/bin/bash

SCRIPT_NAME=$(basename `readlink -f $0`)
ACTIVE_MONITORS=$(xrandr --listactivemonitors | grep -P '^\s*\d:' | awk '{print $NF}' | tr '\n' ' ')

ps auxww|grep plank|grep -Pv "(grep|${SCRIPT_NAME})"|awk '{print $2}'|xargs -i kill -9 {}
for each_monitor in ${ACTIVE_MONITORS[*]};do
    bash -c "cd '${HOME}' && plank -n ${each_monitor} 1>/dev/null 2>&1 &"
done
