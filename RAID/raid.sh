#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
clear
if ! command -v mdadm &>/dev/null
then
    echo -e "${red}The mdadm doesn't exist,please install.${plain}" 
    exit 1
fi
List_raid_type()
{
    raid_type=(
    "raid 0"
    "raid 1"
    "raid 5"
    "raid 10"
    )
    while true
    do
        echo "The raid type:"
        for ((i=1;i<=${#raid_type[@]};i++))
        do
            raid_menu="${raid_type[$i-1]}"
            echo "$i) $raid_menu"
        done
        read -p "Please choose the raid type:" choise_num
        if echo $choise_num | grep -q "[1-4]"
        then
            break
        else
            echo -e "${yellow}Your choise is wrong,please retry.${plain}"
            continue
        fi
    done
}
Add_raid_disk()
{
    function add_disk()
    {
        i=0
        disk_array=()
        while true
        do
            read -e -p "Please choose the disk:" choise_disk
            if echo $choise_disk | grep "^/" | [ -b $choise_disk ]
            then
                disk_array[$i]=$choise_disk
                let i++
                while true
                do
                    read -p "Would you want to add disk(Y/N):" choise_char
                    [ -z $choise_char ] && choise_char=Y
                    case $choise_char in
                        Y|y)
                            continue 2
                            ;;
                        N|n)
                            break 2
                            ;;
                        *)
                            continue
                            ;;
                    esac
                done
            else
                echo -e "${yellow}The disk path is wrong or the disk doesn't exist.${plain}"
            fi
        done
    }
    function raid0_operate()
    {
        if [ $raid_type -eq 0 ]
        then
            disk_limit=2
        fi
        while true
        do
            add_disk
            if [[ ${#disk_array[@]} -lt $disk_limit ]]
            then
                echo -e "${yellow}Raid $raid_type need at least $disk_limit disks.${plain}"
                continue
            else
                break
            fi
        done
        while true
        do
            while true
            do
                read -p "Please input the count of the raid devices:" raid_num
                [ -z $raid_num ] && raid_num=$disk_limit
                if echo "$raid_num" | grep -v "^[0-9]*$" &>/dev/null
                then
                    echo "Your input is wrong,please retry."
                    continue
                elif [[ $raid_num -lt $disk_limit ]]
                then
                    echo -e "${yellow}Raid $raid_type need at least $disk_limit disk.${plain}"
                    continue
                else
                    break
                fi
            done
            if [[ $raid_num -gt ${#disk_array[@]} ]]
            then
                echo -e "${yellow}The count of the raid devices is more than the count of the disk.${plain}"
                continue
            elif [[ $raid_num -lt ${#disk_array[@]} ]]
            then
                disk_array=(${disk_array[@]:0:$raid_num})
                break 
            else
                break
            fi
        done
        mdadm -C /dev/md$raid_type -a yes -l $raid_type -n $raid_num ${disk_array[@]}
    }
    function raid1510_operate()
    {
        if [ $raid_type -eq 1 ]
        then
            disk_limit=2
        elif [ $raid_type -eq 5 ]
        then
            disk_limit=3
        elif [ $raid_type -eq 10 ]
        then
            disk_limit=4
        fi
        while true
        do
            add_disk
            if [ ${#disk_array[@]} -lt $disk_limit ]
            then
                echo -e "${yellow}Raid $raid_type need at least $disk_limit disks.${plain}"
                continue
            else
                break
            fi
        done
        while true
        do
            while true
            do
                read -p "Please input the count of the raid devices:" raid_num
                [ -z $raid_num ] && raid_num=$disk_limit
                if echo "$raid_num" | grep -v "^[0-9]*$" &>/dev/null
                then
                    echo -e "${yellow}Your input is wrong,please retry.${plain}"
                    continue
                elif [[ $raid_num -lt $disk_limit ]]
                then
                    echo -e "${yellow}Raid $raid_type need at least $disk_limit disk.${plain}"
                    continue
                else
                    break
                fi
            done
            while true
            do
                read -p "Please input the count of the spare devices:" spare_num
                [ -z $spare_num ] && spare_num=0
                if echo "$spare_num" | grep -v "^[0-9]*$"  &>/dev/null
                then
                    echo -e "${yellow}Your input is wrong,please retry.${plain}"
                    continue
                elif [ $spare_num -lt 0 ]
                then
                    echo -e "${yellow}Your input must be a positive number,please retry.${plain}"
                else
                    break
                fi
            done
            total_num=`expr $raid_num + $spare_num`
            if [[ $total_num -gt ${#disk_array[@]} ]]
            then
                echo -e "${yellow}The count of the raid devices and spare devices is more than the count of the disk.${plain}"
                continue
            elif [[ $total_num -lt ${#disk_array[@]} ]]
            then
                disk_array=(${disk_array[@]:0:$total_num})
                break 
            else
                break
            fi
        done
        mdadm -C /dev/md$raid_type -a yes -l $raid_type -n $raid_num -x $spare_num ${disk_array[@]}
    }
    case $choise_num in
        1)
            raid_type=0
            raid0_operate
            ;;
        2)
            raid_type=1
            raid1510_operate
            ;;
        3)
            raid_type=5
            raid1510_operate
            ;;
        4)
            raid_type=10
            raid1510_operate
            ;;
    esac
}
Format_raid_disk()
{
    mkfs.ext4 /dev/md$raid_type &>/dev/null
    echo -e "${green}The /dev/md$raid_type has been created,you could use 'cat /proc/mdstat' or 'mdadm -D /dev/md$raid_type' to view status.${plain}"
    mount -t auto /dev/md$raid_type /mnt &>/dev/null
    echo -e "${green}The /dev/md$raid_type has been mounted on /mnt,you could use 'df -h' to view status.${plain}"
    echo "/dev/md$raid_type /mnt ext4 defaults 0 0" >> /etc/fstab
}
Raid_stop()
{
    if [ -b /dev/md0 ]
    then
        raid_type=0
    elif [ -b /dev/md1 ]
    then
        raid_type=1
    elif [ -b /dev/md5 ]
    then
        raid_type=5
    elif [ -b /dev/md10 ]
    then
        raid_type=10
    else
        echo -e "${green}Look like there doesn't exist any raid.${plain}"
        exit
    fi
    umount /dev/md$raid_type &>/dev/null
    echo -e "${green}The /dev/md$raid_type hase been umonted.${plain}"
    mdadm -S /dev/md$raid_type &>/dev/null
    echo -e "${green}The /dev/md$raid_type hase been stoped.${plain}"
    sed -i -e '/\/mnt/d' /etc/fstab
}
Raid_create()
{
    List_raid_type
    Add_raid_disk
    Format_raid_disk
}
action=$1
[ -z $1 ] && action=create
case $action in 
    create|stop)
        Raid_$action
        ;;
    *)
        echo "Arguments error! [${action}]"
        echo "Usage: `basename $0` [install|uninstall]"
        ;;
esac
