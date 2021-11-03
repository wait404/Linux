#!/bin/bash

i=1
while [ $i -lt 255 ]
do
    ping -c 2 192.168.0.$i &> /dev/null
    if [ $? -ne 0 ]
    then
        echo -e "192.168.0.$i  fail\n"
    else
        echo -e "192.168.0.$i  success\n"
    fi
    i=`expr $i + 1`
    sleep 1s
done > ping.log
