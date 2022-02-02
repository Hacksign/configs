#!/bin/bash

(xrandr --listmonitors|grep eDP-1) && exec plank -n eDP-1 1>/dev/null 2>&1 &
(xrandr --listmonitors|grep DP-2-1) && exec plank -n DP-2-1 1>/dev/null 2>&1 &
(xrandr --listmonitors|grep DP-2-2) && exec plank -n DP-2-2 1>/dev/null 2>&1 &
(xrandr --listmonitors|grep HDMI-2) && exec plank -n HDMI-2 1>/dev/null 2>&1 &
(xrandr --listmonitors|grep rdp0) && exec plank -n rdp0 1>/dev/null 2>&1 &
