#!/bin/bash

i=1
while [ $i -lt 255 ]
do
    echo -n "192.168.0.$i"
    if ping -c 2 192.168.0.$i | grep "100% packet loss" &>/dev/null
    then
        echo " fail"
    else
        echo " success"
    fi
    i=`expr $i + 1`
    sleep 1s
done > ping.log
