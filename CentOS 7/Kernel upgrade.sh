#Import the public key:
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

#To install ELRepo for RHEL-7, SL-7 or CentOS-7:
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

#To install ELRepo for RHEL-6, SL-6 or CentOS-6:
#rpm -Uvh http://www.elrepo.org/elrepo-release-6-8.el6.elrepo.noarch.rpm

#To install kernel
yum --enablerepo=elrepo-kernel install  kernel-ml-devel kernel-ml -y

#Check the default startup sequence
awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg

#Set the default start
grub2-set-default 0

#Reboot
reboot

#Remove old kernel
rpm -qa|grep kernel
yum remove kernel-version
