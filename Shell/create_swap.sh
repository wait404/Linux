#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Color
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
#Info
clear
echo
echo "#############################################################"
echo "#                           SWAP                            #"
echo "#############################################################"
echo
#Check permission
[[ `id -u` -ne 0 ]] && echo -e "${red}Please run as root.${plain}" && exit 1
#Check path
while true
do
    read -e -p "Please input the swap path,start with \"/\" and end with \"/\"(Default path is /var/):" dir_path
    [ -z ${dir_path} ] && dir_path=/var/
    if echo "${dir_path}" | grep "^/" | grep "/$" &>/dev/null
    then
        tmp_path=`echo ${dir_path} | sed 's/\/$//'` &>/dev/null
        if [ ! -e ${tmp_path} ]
        then
            while true
            do
                read -p "The path didn't exist,would you want to create(Y/N):" choise_char
                case ${choise_char} in
                    Y|y)
                        mkdir -p ${dir_path}
                        break
                        ;;
                    N|n)
                        echo -e "${red}Exit now!${plain}"
                        exit 1
                        ;;
                    *)
                        echo -e "${yellow}Your choise is wrong,please retry.${plain}"
                        continue
                        ;;
                esac
            done
        elif [ ! -f ${tmp_path} ]
        then
            break
        else
            echo -e "${yellow}The folder has been exist the same name file,please retry.${plain}"
            continue
        fi
    else
        echo -e "${yellow}The path is wrong,please check it and retry.${plain}"
        continue
    fi
done
#Get memtotal number
mem_num=`cat /proc/meminfo | grep "MemTotal" | awk -F : '{print $2}' | tr -cd "[0-9]"`
#Memory more than 0G and less than 4G
if [[ ${mem_num} -ge 0 && ${mem_sum} -le 4194304 ]]
then
    swap_count=2048
fi
#Memory more than 4G and less than 16G
if [[ ${mem_num} -ge 4194304 && ${mem_num} -le 16777216 ]]
then
    swap_count=4096
fi
#Memory more than 16G and less than 64G
if [[ ${mem_num} -ge 16777216 && ${mem_num} -le 67108864 ]]
then
    swap_count=8192
fi
#Memory more than 64G and less than 256G
if [[ ${mem_num} -ge 67108864 && ${mem_num} -le 268435456 ]]
then
    swap_count=16384
fi
echo -e "${green}The swap space is creating now...${plain}"
dd if=/dev/zero of=${dir_path}swap bs=1M count=${swap_count} &>/dev/null
mkswap ${dir_path}swap &>/dev/null
chmod 600 ${dir_path}swap
swapon ${dir_path}swap &>/dev/null
echo "${dir_path}swap swap swap defaults 0 0" >> /etc/fstab
echo -e "${green}The swap space create completed.${plain}"
