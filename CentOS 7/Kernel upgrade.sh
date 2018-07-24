#!/bin/bash
set -e
red='\033[0;31m'
green='\033[0;32m'
plain='\033[0m'
[[ $EUID -ne 0 ]] && echo -e "[${red}Error${plain}] Please run as root." && exit 1
if [ ! -f "/etc/yum.repos.d/elrepo.repo" ]
then
    #Import the public key
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    #To install ELRepo for RHEL-7, SL-7 or CentOS-7
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
fi
#To install kernel
yum --enablerepo=elrepo-kernel install kernel-ml-devel kernel-ml -y
#Set the default start
grub2-set-default 0
#Reboot the system
read -t 10 -p "Would you want to reboot the system(Y/N):" choicechar
case $choicechar in
    Y|y)
        init 6
        ;;
    N|n)
        echo -e "${green}Good Bye!${plain}"
        ;;
    *)
        echo -e "${red}Input Error!${plain}"
        ;;
esac
