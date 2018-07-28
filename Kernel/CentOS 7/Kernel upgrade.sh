#!/bin/bash
set -e
red='\033[0;31m'
green='\033[0;32m'
plain='\033[0m'
[[ `id -u` -ne 0 ]] && echo -e "${red}Please run as root.${plain}" && exit 1
#Install yum-utils
if [ `rpm -qa | grep yum-utils | wc -l` -eq 0 ]
then
    yum install yum-utils -y
fi
#Install elrepo
if [ `rpm -qa | grep elrepo-release | wc -l` -eq 0 ]
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
