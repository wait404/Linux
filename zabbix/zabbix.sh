#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

red='\033[0;31m'
green='\033[0;32m'
plain='\033[0m'

zabbix_file=https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/3.0.25/zabbix-3.0.25.tar.gz/download
zabbix_path=/usr/local/zabbix
src_path=/usr/local/src
chinese_font_file=https://github.com/wait404/Linux/raw/master/zabbix/simkai.ttf

[ "$EUID" -ne 0 ] && echo -e "${red}请使用root运行此脚本。${plain}" && exit 1
[ ! -e /etc/redhat-release ] && echo -e "${red}此脚本目前仅适配CentOS。${plain}" && exit 1
[ `ps -ef | grep mysql | grep -v grep | wc -l` -eq 0 ] && echo -e "${red}请安装或启动MySQL。${plain}" && exit 1

function Install_warn()
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
function Uninstall_warn()
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
        if [ -z "$database_root_password" ]
        then
            echo -e "${red}密码为空，请重新输入。${plain}"
        continue
        elif
            echo `mysql -u root -p$database_root_password -e quit 2>&1` | grep -q "ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)"
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
        if [ -z "$database_zabbix_password" ]
        then
            echo -e "${red}密码不能为空。${plain}"
            continue
        else
            break
        fi
    done
}
function Zabbix_web()
{
    while true
    do
        read -e -p "选择zabbix web目录：（默认为/home/wwwroot/zabbix）" zabbix_web_path
        if [ -z "$zabbix_web_path" ]
        then
            mkdir -p /home/wwwroot/zabbix
            zabbix_web_path=/home/wwwroot/zabbix
            break
        elif [ -f "$zabbix_web_path" ]
        then
            echo -e "${yellow}已存在同名文件，请重新选择。${plain}"
            continue
        elif [ ! -e "$zabbix_web_path" ]
        then
            mkdir -p $zabbix_web_path
            echo -e "该目录不存在，已创建目录$zabbix_web_path。"
            break
        else
            break
        fi
    done
}
function Zabbix_font()
{
    while true
    do
        read -p "是否替换为中文字体(Y/N):" -e -i Y chinese_font
        case $chinese_font in
            Y|y)
                break
                ;;
             N|n)
                break
                ;;
            *)
                continue
                ;;
        esac
    done
}
function Install_zabbix()
{
    groupadd zabbix &> /dev/null
    useradd -M -s /sbin/nologin -g zabbix zabbix &> /dev/null
    yum install -y gcc make net-snmp-devel libxml2-devel libcurl-devel libevent-devel libssh2-devel mysql-devel openldap*
    wget $zabbix_file -O $src_path/zabbix.tar.gz
    tar -zxvf $src_path/zabbix.tar.gz -C $src_path
    cd $src_path/zabbix-3.0.25
    ./configure --prefix=$zabbix_path --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2 --enable-proxy --with-ldap --with-openssl --with-ssh2
    make && make install
    mysql -u root -p$database_root_password -e "create user 'zabbix'@'localhost' identified by \"$database_zabbix_password\"" &>/dev/null
    mysql -u root -p$database_root_password -e "create database zabbix" &>/dev/null
    mysql -u root -p$database_root_password -e "grant all privileges on zabbix.* to 'zabbix'@'localhost'" &>/dev/null
    mysql -u zabbix -p$database_zabbix_password zabbix < $src_path/zabbix-3.0.25/database/mysql/schema.sql &> /dev/null
    mysql -u zabbix -p$database_zabbix_password zabbix < $src_path/zabbix-3.0.25/database/mysql/images.sql &> /dev/null
    mysql -u zabbix -p$database_zabbix_password zabbix < $src_path/zabbix-3.0.25/database/mysql/data.sql &> /dev/null
    sed -i "s#BASEDIR=/usr/local#BASEDIR=$zabbix_path#g" $src_path/zabbix-3.0.25/misc/init.d/fedora/core/zabbix_*
    mv $src_path/zabbix-3.0.25/misc/init.d/fedora/core/zabbix_* /etc/init.d/
    chmod a+x /etc/init.d/zabbix_*
    sed -i "s#\# DBPassword=#DBPassword=$database_zabbix_password#g" $zabbix_path/etc/zabbix_server.conf
    mysql_sock_path=`find / -name mysql.sock`
    sed -i "s#\# DBSocket=/tmp/mysql.sock#DBSocket=$mysql_sock_path#g" $zabbix_path/etc/zabbix_server.conf
    mv $src_path/zabbix-3.0.25/frontends/php/* $zabbix_web_path
    chown -R www:www $zabbix_web_path

    if [[ "$chinese_font" == 'Y' || "$chinese_font" == 'y' ]]
    then
        wget $chinese_font_file $zabbix_web_path/fonts/
        sed -i 's#DejaVuSans#simkai#g' $zabbix_web_path/include/defines.inc.php
    fi
    service zabbix_server start
    service zabbix_agentd start
    chkconfig --level 2345 zabbix_server on
    chkconfig --level 2345 zabbix_agentd on
    echo -e "${green}安装完成，zabbix数据库密码为$database_zabbix_password，请妥善保管，web目录路径为$zabbix_web_path。${plain}"
}
function Clean_temp_file()
{
    rm -rf $src_path/zabbix-3.0.25 $src_path/zabbix.tar.gz
}
function Uninstall_zabbix()
{
    check_zabbix_file=`find / -name "*zabbix*"`
    if [ -z "$check_zabbix_file" ]
    then
        echo -e "${green}似乎没有安装zabbix。${plain}"
    else
        service zabbix_server stop
        service zabbix_agentd stop
        chkconfig --del zabbix_server
        chkconfig --del zabbix_agentd
        systemctl daemon-reload
        DB_root_password
        mysql -u root -p$database_root_password -e "revoke all privileges on zabbix.* from 'zabbix'@'localhost'" &>/dev/null
        mysql -u root -p$database_root_password -e "drop database zabbix" &>/dev/null
        mysql -u root -p$database_root_password -e "drop user 'zabbix'@'localhost'" &>/dev/null
        userdel zabbix &> /dev/null
        groupdel zabbix &> /dev/null
        find / -name "*zabbix*" -exec rm -rf {} \; &> /dev/null
    fi
}
function Install_the_zabbix()
{
    Install_warn
    DB_root_password
    DB_zabbix_password
    Zabbix_web
    Zabbix_font
    Install_zabbix
    Clean_temp_file
}
function Uninstall_the_zabbix()
{
    Uninstall_warn
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
    case $choise_num in
        1)
            Install_the_zabbix
            break
            ;;
        2)
            Uninstall_the_zabbix
            break
            ;;
        3)
            exit 1
            ;;
        *)
            echo -e "${yellow}选择错误，请重新选择。${plain}"
            continue
            ;;
    esac
done
