#!/bin/bash

while true
do
    amixer scontrols | grep 'Master' 1>/dev/null 2>&1
    if [ $? == 0 ];then
        volumeicon 1>/dev/null 2>&1
        exit
    else
        sleep 1
    fi
done

