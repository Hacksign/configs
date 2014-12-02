#!/usr/bin/bash

Xephyr -ac -br -noreset -screen 800x600 :1.0 &
ZEPHYR_PID=$!
sleep 1
DISPLAY=:1.0 awesome -c ~/.config/awesome/rc.lua
kill $ZEPHYR_PID
