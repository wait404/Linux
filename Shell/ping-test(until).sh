#!/bin/bash

i=1
until [ $i -gt 254 ]
do
    ping -c 2 192.168.0.$i &> /dev/null
    if [ $? -ne 0 ]
    then
        echo -e "192.168.0.$i  fail\n"
    else
        echo -e "192.168.0.$i  success\n"
    fi
    i=$[$i+1]
    sleep 1s
done > ping.log
