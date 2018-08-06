#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
choise_menu=(
2-\>10
8-\>10
16-\>10
)
while true
do
    for ((i=1;i<=${#choise_menu[@]};i++))
    do
        tmp_menu="${choise_menu[$i-1]}"
        echo "$i) ${tmp_menu}"
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
                echo $((2#$input_num))
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
            if echo "${input_num}" | grep "^[0-7]*$" &>/dev/null
            then
                echo -n "The result is:"
                echo $((8#$input_num))
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
            if echo "${input_num}" | grep "^[0-9a-fA-F]*$" &>/dev/null
            then
                echo -n "The result is:"
                echo $((16#$input_num))
                break
            else
                echo -e "${yellow}The input is wrong,please retry.${plain}"
                continue
            fi
        done
        ;;
esac
