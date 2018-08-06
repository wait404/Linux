#!/bin/bash
for i in {1..254}
do
    echo -n "192.168.0.$i"
    if ping -c 2 192.168.0.$i | grep "100% packet loss" &>/dev/null
    then
        echo "  fail"
    else
        echo "  success"
    fi
    let i++
    sleep 1s
done > ping.log
