#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

red='\033[0;31m'
green='\033[0;32m'
plain='\033[0m'

aria2_download_link=https://github.com/aria2/aria2/archive/release-1.34.0.tar.gz
aria2_script_download_link=https://raw.githubusercontent.com/wait404/Linux/master/aria2/aria2
aria2_config_download_link=https://raw.githubusercontent.com/wait404/Linux/master/aria2/aria2.conf
aria2_magic_config_download_link=https://raw.githubusercontent.com/wait404/Linux/master/aria2/aria2-magic.conf
src_path=/usr/local/src

[ "$EUID" -ne 0 ] && echo -e "${red}请使用root运行此脚本。${plain}" && exit 1

if [ ! -e /etc/os-release ]
then
    echo -e"${red}此脚本可能无法执行。${plain}"
    exit 1
fi
source /etc/os-release
if [[ "$ID" == 'debian' || "$ID" == 'ubuntu' || "$ID" == 'deepin' || "$ID" == 'kali' ]]
then
    os_type=debians
elif [[ "$ID" == 'centos' || "$ID" == 'fedora' || "$ID" == 'rhel' ]]
then
    os_type=rhels
else
    echo -e"${red}此脚本可能无法在您的系统上执行。${plain}"
    exit 1
fi
function Install_dependency()
{
    if [ "$os_type" == 'debians' ]
    then
        apt install -y libssh2-1-dev libc-ares-dev libxml2-dev zlib1g-dev libsqlite3-dev pkg-config libssl-dev libcppunit-dev autoconf automake autotools-dev autopoint libtool gcc g++ make sysv-rc-conf
    fi
    if [ "$os_type" == 'rhels' ]
    then
        yum install -y libgcrypt-devel libxml2-devel libssh2-devel openssl-devel gettext-devel cppunit cppunit-devel  c-ares-devel zlib-devel sqlite-devel pkgconfig libtool autoconf automake chkconfig gcc gcc-c++ make xorg-x11-util-macros.noarch dh-autoreconf.noarch
    fi
}
function Get_aria2()
{
    wget $aria2_download_link -O $src_path/aria2.tar.gz
    tar -zxvf $src_path/aria2.tar.gz -C $src_path
    #fix a bug.
    sed -i "s#AM_GNU_GETTEXT_VERSION(\[0.18\])#AM_GNU_GETTEXT_VERSION(\[0.19\])#g" $src_path/aria2-release-1.34.0/configure.ac
}
function Edit_aria2()
{
    sed -i "s#\"1\", 1, 16, 'x'#\"1\", 1, 1024, 'x'#g" $src_path/aria2-release-1.34.0/src/OptionHandlerFactory.cc 
}
function Install_aria2()
{
    cd $src_path/aria2-release-1.34.0
    autoreconf -i
    ./configure
    make -j `cat /proc/cpuinfo | grep -c processor` && make install
}
function Misc_aria2()
{
    groupadd aria2
    useradd -m -s /sbin/nologin -g aria2 aria2
    mkdir -p /etc/aria2 
}
function Config_aria2()
{
    wget $aria2_config_download_link -O /etc/aria2/aria2.conf
    wget $aria2_script_download_link -O /etc/init.d/aria2
    chown -R aria2:aria2 /etc/aria2
    chown root:root /etc/init.d/aria2
    chmod a+x /etc/init.d/aria2
    systmctl unmask aria2
    service start aria2
    if [ "$os_type" == 'debians' ]
    then
        sysv-rc-conf aria2 on
    fi
    if [ "$os_type" == 'rhels' ]
    then
        chkconfig --add aria2
    fi
}
function Config_magic_aria2()
{
    wget $aria2_magic_config_download_link -O /etc/aria2/aria2.conf
    wget $aria2_script_download_link -O /etc/init.d/aria2
    chown -R aria2:aria2 /etc/aria2
    chown root:root /etc/init.d/aria2
    chmod a+x /etc/init.d/aria2
    systemctl unmask aria2
    service start aria2
    if [ "$os_type" == 'debians' ]
    then
        sysv-rc-conf aria2 on
    fi
    if [ "$os_type" == 'rhels' ]
    then
        chkconfig --add aria2
    fi
}
function Clean_temp()
{
    rm -rf $src_path/aria2*
}
function Install_the_aria2()
{
    Install_dependency
    Get_aria2
    Install_aria2
    Misc_aria2
    Config_aria2
    Clean_temp
}
function Install_magic_aria2()
{
    Install_dependency
    Get_aria2
    Edit_aria2
    Install_aria2
    Misc_aria2
    Config_magic_aria2
    Clean_temp
}
function Uninstall_the_aria2()
{
    rm -rf /usr/local/bin/aria2c /etc/init.d/aria2 /etc/aria2 /home/aria2
    groupdel aria2
    userdel -rf aria2
}
aria2_array=("安装aria2" "安装魔改版aria2" "卸载aria2" "退出")
for ((i=1;i<=${#aria2_array[@]};i++))
do
    aria2_menu=${aria2_array[$i-1]}
    echo -e "${green}$i) $aria2_menu${plain}"
done
while true
do
    read -p "请选择：" choise_num
    case $choise_num in
        1)
            Install_the_aria2
            break
            ;;
        2)
            Install_magic_aria2
            break
            ;;
        3)
            Uninstall_the_aria2
            break
            ;;
        4)
            exit 0
            break
            ;;
        *)
            echo -e "${yellow}选择错误，请重新选择。${plain}"
            continue
            ;;
    esac
done
