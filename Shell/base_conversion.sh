#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Color
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
#Check the bc
[[ `rpm -qa | grep "^bc" | wc -l` -eq 0 ]] && echo -e "${red}You need to install bc.${plain}" && exit 1
#list the menu
choise_menu=(
2-\>8
2-\>10
2-\>16
8-\>2
8-\>10
8-\>16
10-\>2
10-\>8
10-\>16
16-\>2
16-\>8
16-\>10
)
#Check the choise
while true
do
    for ((i=1;i<=${#choise_menu[@]};i++ ))
    do
        tmp_menu="${choise_menu[$i-1]}"
        echo "$i ${tmp_menu}"
    done
    read -p "Please choose the base conversion type:" choise_num
    if [[ ${choise_num} -ge 1 && ${choise_num} -le ${#choise_menu[@]} ]]
    then
        break
    else
        echo -e "${yellow}The input is wrong,please retry.${plain}"
        continue
    fi
done
case ${choise_num} in
    1)
        while true
        do
            read -p "Please input the number:" input_num
            if echo "${input_num}" | grep "^[0-1]*$" &>/dev/null
            then
                echo -n "The result is:"
                echo "ibase=8;ibase=2;${input_num}" | bc
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
    2)
        while true
        do
            read -p "Please input the number:" input_num
            if echo "${input_num}" | grep "^[0-1]*$" &>/dev/null
            then
                echo -n "The result is:"
                echo "obase=10;ibase=2;${input_num}" | bc
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
    3)
        while true
        do
            read -p "Please input the number:" input_num
            if echo "${input_num}" | grep "^[0-1]*$" &>/dev/null
            then
                echo -n "The result is:"
                echo "obase=16;ibase=2;${input_num}" | bc
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
    3)
        while true
        do
            read -p "Please input the number:" input_num
            if echo "${input_num}" | grep "^[0-1]*$" &>/dev/null
            then
                echo -n "The result is:"
                echo "obase=16;ibase=2;${input_num}" | bc
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
    4)
        while true
        do
            read -p "Please input the number:" input_num
            if echo "${input_num}" | grep "^[0-7]*$" &>/dev/null
            then
                echo -n "The result is:"
                echo "obase=2;ibase=8;${input_num}" | bc
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
    5)
        while true
        do
            read -p "Please input the number:" input_num
            if echo "${input_num}" | grep "^[0-7]*$" &>/dev/null
            then
                echo -n "The result is:"
                echo "obase=10;ibase=8;${input_num}" | bc
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
    6)
        while true
        do
            read -p "Please input the number:" input_num
            if echo "${input_num}" | grep "^[0-7]*$" &>/dev/null
            then
                echo -n "The result is:"
                echo "obase=16;ibase=8;${input_num}" | bc
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
    7)
        while true
        do
            read -p "Please input the number:" input_num
            if echo "${input_num}" | grep "^[0-9]*$" &>/dev/null
            then
                echo -n "The result is:"
                echo "obase=2;ibase=10;${input_num}" | bc
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
    8)
        while true
        do
            read -p "Please input the number:" input_num
            if echo "${input_num}" | grep "^[0-9]*$" &>/dev/null
            then
                echo -n "The result is:"
                echo "obase=8;ibase=10;${input_num}" | bc
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
    9)
        while true
        do
            read -p "Please input the number:" input_num
            if echo "${input_num}" | grep "^[0-9]*$" &>/dev/null
            then
                echo -n "The result is:"
                echo "obase=16;ibase=10;${input_num}" | bc
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
    10)
        while true
        do
            read -p "Please input the number:" input_num
            if echo "${input_num}" | grep "^[0-9a-fA-F]*$" &>/dev/null
                if echo "${input_num}" | grep "[a-f]" &>/dev/null
                then
                    input_num=`echo "${input_num}" | tr a-f A-F`
                fi
            then
                echo -n "The result is:"
                echo "obase=2;ibase=16;${input_num}" | bc
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
    11)
        while true
        do
            read -p "Please input the number:" input_num
            if echo "${input_num}" | grep "^[0-9a-fA-F]*$" &>/dev/null
                if echo "${input_num}" | grep "[a-f]" &>/dev/null
                then
                    input_num=`echo "${input_num}" | tr a-f A-F`
                fi
            then
                echo -n "The result is:"
                echo "obase=8;ibase=16;${input_num}" | bc
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
    12)
        while true
        do
            read -p "Please input the number:" input_num
            if echo "${input_num}" | grep "^[0-9a-fA-F]*$" &>/dev/null
                if echo "${input_num}" | grep "[a-f]" &>/dev/null
                then
                    input_num=`echo "${input_num}" | tr a-f A-F`
                fi
            then
                echo -n "The result is:"
                echo "obase=10;ibase=16;${input_num}" | bc
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
esac
