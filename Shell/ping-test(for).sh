#!/bin/bash
for i in {1..254}
do
    ping -c 2 192.168.0.$i &> /dev/null
    if [ $? -ne 0 ]
    then
        echo -e "192.168.0.$i  fail\n"
    else
        echo -e "192.168.0.$i  success\n"
    fi
    let i++
    sleep 1s
done > ping.log
