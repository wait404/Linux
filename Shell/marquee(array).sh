#!/usr/bin/env bash

array_list=("欢" "迎" "光" "临" "!")
array_len=${#array_list[@]}
while true
do
    clear
    array_list[${array_len}]=${array_list[0]}
    for ((i=0;i<${array_len};i++))
    do
        echo -n ${array_list[$i]}
        array_list[$i]=${array_list[$i+1]}
    done
    sleep 0.3
done
