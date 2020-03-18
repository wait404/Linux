#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
plain='\033[0m'
[[ $EUID -ne 0 ]] && echo "${red}Please run as root.${plain}" && exit 1
while true
do
    read -p "Please input the count of the user you want to add:" user_num
    if echo $user_num | grep -v "^[0-9]*$" &>/dev/null
    then
        echo "${yellow}Your input is wrong,please retry.${plain}"
        continue
    elif [ $user_num -le 0 ]
    then
        echo "${yellow}Your input must be greater than 0.${plain}"
        continue
    else
        break
    fi
done
for ((i=1;i<=$user_num;i++))
do
    useradd -m -s `which bash` user$i
    p1=`echo $RANDOM | md5sum | cut -c -5` &>/dev/null
    p2=`uuidgen | awk -F - '{print $2}' | tr [a-z] [A-Z]` &>/dev/null
    user_passwd=$p1-$p2
    echo "user:user$i passwd:$user_passwd" >> passwd.txt
    echo $user_passwd | passwd --stdin user$i &>/dev/null
    chage -d 0 user$i &>/dev/null
done
echo "${green}The user has been created,and the password was in the passwd.txt,please delete after use.${plain}"
