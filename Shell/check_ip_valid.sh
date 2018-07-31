#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

read -p "please input a ip address:" ip_addr
valid_check=`echo ${ip_addr} | awk -F . '$1<=255&&$2<=255&&$3<=255&&$4<=255{print "yes"}'`
if echo ${ip_addr} | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" > /dev/null
then
    if [[ ${valid_check:-no} == "yes" ]]
    then
        echo "${ip_addr} is a ip address."
    else
        echo "${ip_addr} isn't a ip address."
    fi
else
    echo "${ip_addr} isn't a ip address."
fi
