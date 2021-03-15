#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

zabbix_file=https://cdn.zabbix.com/zabbix/sources/stable/5.0/zabbix-5.0.9.tar.gz
zabbix_path=/usr/local/zabbix
src_path=/usr/local/src
simkai_font_file=https://github.com/wait404/Linux/raw/master/zabbix/simkai.ttf

[ "$EUID" -ne 0 ] && echo -e "${red}请使用root运行此脚本。${plain}" && exit 1
[ ! -e /etc/redhat-release ] && echo -e "${red}此脚本目前仅适配CentOS。${plain}" && exit 1

pidof mysqld &> /dev/null
[ "$?" -ne 0 ] && echo -e "${red}请安装或启动MySQL。${plain}" && exit 1

function Install_notice()
{
    while true
    do
        read -p "是否安装zabbix(Y/N):" -e -i Y choice_char
        case $choice_char in
            Y|y)
                break
                ;;
            N|n)
                echo -e "${yellow}安装中断。${plain}"
                exit 1
                ;;
            *)
                continue
                ;;
        esac
    done
}
function Uninstall_notice()
{
    while true
    do
        read -p "是否卸载zabbix(Y/N):" -e -i Y choice_char
        case $choice_char in
            Y|y)
                break
                ;;
            N|n)
                echo -e "${yellow}卸载中断。${plain}"
                exit 1
                ;;
            *)
                continue
                ;;
        esac
    done
}
function DB_root_password()
{
    while true
    do
        read -s -p "请输入mysql root密码：" database_root_password
        echo
        if [ -z "${database_root_password}" ]
        then
            echo -e "${red}密码为空，请重新输入。${plain}"
            continue
        fi
        mysql -u root -p${database_root_password} -e "quit" &> /dev/null
        if [ "$?" -ne 0 ]
        then
            echo -e "${red}密码错误，请重新输入。${plain}" 
            continue
        else
            break
        fi
    done
}
function DB_zabbix_password()
{
    while true
    do
        read -s -p "请输入zabbix的数据库密码：" database_zabbix_password
        echo
        if [ -z "${database_zabbix_password}" ]
        then
            echo -e "${red}密码不能为空。${plain}"
            continue
        else
            break
        fi
    done
}
function Web_path()
{
    while true
    do
        read -e -p "选择zabbix web目录（默认为/home/wwwroot/zabbix）：" zabbix_web_path
        if [ -z "${zabbix_web_path}" ]
        then
            zabbix_web_path=/home/wwwroot/zabbix
            mkdir -p ${zabbix_web_path}
            break
        elif [ -f "${zabbix_web_path}" ]
        then
            echo -e "${yellow}已存在同名文件，请重新选择。${plain}"
            continue
        elif [ ! -e "${zabbix_web_path}" ]
        then
            mkdir -p ${zabbix_web_path}
            echo -e "该目录不存在，已创建目录${zabbix_web_path}。"
            break
        else
            break
        fi
    done
}
function Install_zabbix()
{
    groupadd zabbix &> /dev/null
    useradd -M -s `which nologin` -g zabbix zabbix &> /dev/null
    yum install -y gcc gcc-c++ make mysql-devel net-snmp net-snmp-devel libxml2 libxml2-devel libcurl libcurl-devel libevent libevent-devel libssh2 libssh2-devel openldap openldap-devel unixODBC-devel OpenIPMI OpenIPMI-devel ipmitool freeipmi
    wget ${zabbix_file} -O ${src_path}/zabbix.tar.gz
    tar -zxf ${src_path}/zabbix.tar.gz -C ${src_path}
    cd ${src_path}/zabbix-5.0.9
    ./configure --prefix=${zabbix_path} --enable-server --enable-agent --enable-proxy --enable-ipv6 --with-mysql --with-net-snmp --with-libcurl --with-libxml2 --with-ldap --with-openssl --with-ssh2 --with-unixodbc
    make && make install
    mysql -u root -p${database_root_password} -e "create user 'zabbix'@'localhost' identified by \"${database_zabbix_password}\"" &>/dev/null
    mysql -u root -p${database_root_password} -e "create database zabbix charset utf8 collate utf8_bin" &>/dev/null
    mysql -u root -p${database_root_password} -e "grant all privileges on zabbix.* to 'zabbix'@'localhost'" &>/dev/null
    mysql -u zabbix -p${database_zabbix_password} zabbix < ${src_path}/zabbix-5.0.9/database/mysql/schema.sql &> /dev/null
    mysql -u zabbix -p${database_zabbix_password} zabbix < ${src_path}/zabbix-5.0.9/database/mysql/images.sql &> /dev/null
    mysql -u zabbix -p${database_zabbix_password} zabbix < ${src_path}/zabbix-5.0.9/database/mysql/data.sql &> /dev/null
    sed -i "s#BASEDIR=/usr/local#BASEDIR=$zabbix_path#g" ${src_path}/zabbix-5.0.9/misc/init.d/fedora/core/zabbix_*
    \cp ${src_path}/zabbix-5.0.9/misc/init.d/fedora/core/zabbix_* /etc/init.d/
    chmod a+x /etc/init.d/zabbix_*
    sed -i "s#\# DBPassword=#DBPassword=${database_zabbix_password}#g" ${zabbix_path}/etc/zabbix_server.conf
    mysql_sock_path=`find / -name mysql.sock`
    sed -i "s#\# DBSocket=#DBSocket=${mysql_sock_path}#g" ${zabbix_path}/etc/zabbix_server.conf
    \cp -r ${src_path}/zabbix-5.0.9/ui/* ${zabbix_web_path}
    wget ${simkai_font_file} -O ${zabbix_web_path}/assets/fonts/simkai.ttf
    sed -i 's#DejaVuSans#simkai#g' ${zabbix_web_path}/include/defines.inc.php
    chown -R www:www ${zabbix_web_path}

    service zabbix_server start
    service zabbix_agentd start
    chkconfig --level 2345 zabbix_server on
    chkconfig --level 2345 zabbix_agentd on
    echo -e "${green}安装完成，zabbix数据库密码为${database_zabbix_password}，请妥善保管，web目录路径为${zabbix_web_path}。${plain}"
}
function Clean_temp_file()
{
    rm -rf ${src_path}/zabbix-5.0.9 ${src_path}/zabbix.tar.gz
}
function Uninstall_zabbix()
{
    DB_root_password
    service zabbix_server stop
    service zabbix_agentd stop
    chkconfig --del zabbix_server
    chkconfig --del zabbix_agentd
    systemctl daemon-reload
    mysql -u root -p${database_root_password} -e "revoke all privileges on zabbix.* from 'zabbix'@'localhost'" &>/dev/null
    mysql -u root -p${database_root_password} -e "drop database zabbix" &>/dev/null
    mysql -u root -p${database_root_password} -e "drop user 'zabbix'@'localhost'" &>/dev/null
    userdel zabbix &> /dev/null
    groupdel zabbix &> /dev/null
    rm -rf /home/wwwroot/zabbix /usr/local/zabbix /etc/init.d/zabbix_{server,agentd} /tmp/zabbix*
    echo -e "${green}卸载完成。${plain}"
}
function Install_the_zabbix()
{
    Install_notice
    DB_root_password
    DB_zabbix_password
    Web_path
    Install_zabbix
    Clean_temp_file
}
function Uninstall_the_zabbix()
{
    Uninstall_notice
    Uninstall_zabbix
}
echo -e "${green}运行此脚本前，请确认搭建完成lnmp环境并启动。${plain}"
echo
while true
do
    echo -e "${green}1.安装zabbix。${plain}"
    echo -e "${green}2.卸载zabbix。${plain}"
    echo -e "${green}3.退出脚本。${plain}"
    read -p "请选择：" choise_num
    case ${choise_num} in
        1)
            Install_the_zabbix
            break
            ;;
        2)
            Uninstall_the_zabbix
            break
            ;;
        3)
            echo -e "${green}已退出。${plain}"
            exit 1
            ;;
        *)
            echo -e "${yellow}选择错误，请重新选择。${plain}"
            continue
            ;;
    esac
done
