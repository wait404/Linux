#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Clolr
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
#Info
clear
echo
echo "#############################################################"
echo "#                             NFS                           #"
echo "#https://github.com/wait404/Linux/blob/master/NFS/README.md #"
echo "#############################################################"
echo
#Check permission
[[ `id -u` -ne 0 ]] && echo -e "${red}Please run as root.${plain}" && exit 1
#Check choise char
function check_choise_char()
{
    local choise_char=$1
    choise_char_array=(m M n N y Y)
    if [ -z "$choise_char" ]
    then
        return 1
    elif echo "${choise_char_array[@]}" | grep -q "$choise_char"
    then
        return 0
    else
        echo -e "${yellow}输入错误，请重新输入。${plain}"
        return 1
    fi
}
#Use while loop
function use_while_loop()
{
    local read_char=$1
    while true
    do
        read -p $read_char choise_char
        check_choise_char $choise_char
        [ "$?" -eq 0 ] && break
    done
}
Choose_folder()
{
    while true
    do
        read -e -p "请选择共享目录：" folder_path
        if echo "$folder_path" | grep -Eq "^/|^~"
        then
            if [ ! -f "$folder_path" ]
            then
                break
            else
                echo -e "${yellow}已存在同名文件，请重新输入。${plain}"
                continue
            fi
        else
            echo -e "${yellow}路径错误，请重新输入。${plain}"
            continue
        fi
    done
    if [ ! -d "$folder_path" ]
    then
        while true
        do
            read -p "该目录不存在，是否创建(Y/N)：" choise_char
            if [ -z "$choise_char" ]
            then
                continue
            elif [[ "$choise_char" = Y || "$choise_char" = y ]]
            then
                mkdir -p $folder_path
                chmod 777 $folder_path
                break
            elif [[ "$choise_char" = N || "$choise_char" = n ]]
            then
                echo -e "${yellow}正在退出。。。${plain}"
                exit 1
            else
                continue
            fi
        done
    else
        chmod 777 $folder_path
    fi
}
Edit_exports()
{
    while true
    do
        read -p "请输入客户端IP，IP段，组群或域：" the_host
        if [ -z "$the_host" ]
        then
            continue
        else
            break
        fi
    done
    read_char="是否允许客户端写入(Y/N/M):"
    use_while_loop $read_char
    case $choise_char in
        Y|y)
            the_host_write=rw
            read_char="是否同步写入磁盘(Y/N/M)："
            use_while_loop $read_char
            case $choise_char in
                Y|y)
                    the_host_sync=,sync
                    ;;
                N|n)
                    the_host_sync=,rsync
                    ;;
                M|m)
                    the_host_sync=
                    ;;
            esac
            read_char="是否一起执行写操作(Y/N/M)："
            use_while_loop $read_char
            case $choise_char in
                Y|y)
                    the_host_wdelay=,wdelay
                    ;;
                N|n)
                    the_host_wdelay=,no_wdelay
                    ;;
                M|m)
                    the_host_wdelay=
                    ;;
            esac
            ;;
        N|n)
            the_host_write=ro
            ;;
        M|m)
            the_host_write=ro
            ;;
    esac
    read_char="是否客户端只能从小于1024的端口进行连接(Y/N/M)："
    use_while_loop $read_char
    case $choise_char in
        Y|y)
            the_host_secure=,secure
            ;;
        N|n)
            the_host_secure=,insecure
            ;;
        M|m)
            the_host_secure=
            ;;
    esac
    read_char="是否检查父目录的权限(Y/N/M)："
    use_while_loop $read_char
    case $choise_char in
        Y|y)
            the_host_subtree=,subtree_check
            ;;
        N|n)
            the_host_subtree=,no_subtree_check
            ;;
        M|m)
            the_host_subtree=
            ;;
    esac
    read_char="是否映射为匿名用户及用户群组(Y/N/M)：" 
    use_while_loop $read_char
    case $choise_char in
        Y|y)
            the_host_all_squash=,all_squash
            ;;
        N|n)
            the_host_all_squash=,no_all_aquash
            ;;
        M|m)
            the_host_all_squash=
            ;;
    esac
    read_char="是否将root用户及所属用户群组映射为匿名用户及用户群组(Y/N/M)："
    use_while_loop $read_char
    case $choise_char in
        Y|y)
            the_host_root_squash=,root_squash
            ;;
        N|n)
            the_host_root_squash=,no_root_aquash
            ;;
        M|m)
            the_host_root_squash=
            ;;
    esac
    echo "$folder_path $the_host($the_host_write$the_host_sync$the_host_secure$the_host_wdelay$the_host_subtree$the_host_all_squash$the_host_root_squash)" >>  /etc/exports
}
#Install service
Install_service()
{
    if [ `rpm -qa |grep "nfs-utils" | wc -l` -eq 0 ]
    then
        yum install nfs-utils -y &>/dev/null
    fi
    if [ `rpm -qa |grep "nfs-rpcbind" | wc -l` -eq 0 ]
    then
        yum install rpcbind -y &>/dev/null
    fi
}
#Start the service
Start_service()
{
    service_status=`rpcinfo -p | grep "nfs" | wc -l`
    if [ "$service_status" -eq 0 ]
    then
        systemctl start rpcbind
        systemctl enable rpcbind &>/dev/null
        systemctl start nfs
        systemctl enable nfs &>/dev/null
        echo -e "${green}服务启动成功。${plain}"
    else
        systemctl restart rpcbind
        systemctl enable rpcbind &>/dev/null
        systemctl restart nfs
        systemctl enable nfs &>/dev/null
        echo -e "${green}服务已经启动。${plain}"
    fi
}
#Test the service
Test_service()
{
    ip_addr=`ip addr | grep "inet" | grep -v "inet6" | grep -Ev "127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | head -n 1`
    echo -e "${green}可使用 mount -t auto $ip_addr:$folder_path /mnt 进行挂载测试。${plain}"
    echo -e "${green}可在服务器使用 nfsstat -s 查看服务器信息。${plain}"
    echo -e "${green}可在客户端使用 nfsstat -c 查看客户端信息。${plain}"
    echo -e "${green}可在客户端使用 showmount -e $ip_addr 查看服务器输出目录。${plain}"
    echo -e "${green}可在服务器/客户端使用${plain}"
    echo -e "${green}                    rpcinfo -u $ip_addr rpcbind${plain}"
    echo -e "${green}                    rpcinfo -u $ip_addr nfs${plain}"
    echo -e "${green}                    rpcinfo -u $ip_addr mountd${plain}"
    echo -e "${green}查看服务器RPC服务信息。${plain}"
}
NFS_install()
{
    Choose_folder
    Edit_exports
    Install_service
    Start_service
    Test_service
}
NFS_remove()
{
    if [ `rpm -qa |grep "nfs-utils" | wc -l` -eq 0 ]
    then
        echo -e "${yellow}看起来你并没有安装NFS。${plain}"
        exit 0
    else
        while true
        do
            read -p "是否确认卸载NFS(Y/N)：" choise_char
            if [ -z "$choise_char" ]
            then
                continue
            elif [[ "$choise_char" = Y || "$choise_char" = y ]]
            then
                systemctl stop nfs-utils &>/dev/null
                systemctl disable nfs-utils &>/dev/null
                yum remove nfs-utils -y &>/dev/null
                cat /dev/null > /etc/exports
                echo -e "${green}NFS已卸载成功。${plain}"
                exit 0
            elif [[ "$choise_char" = N || "$choise_char" = n ]]
            then
                echo -e "${green}卸载已中止。${plain}"
                exit 1
            else
                continue
            fi
        done
    fi
}
action=$1
[ -z "$action" ] && action=install
case $action in
    install|remove)
        NFS_$action
        ;;
    *)
        echo -e "${yellow}Arguments error! [${action}]${plain}"
        echo -e "${yellow}Usage: `basename $0` [install|remove]${plain}"
        ;;
esac
