## Import the public key:
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

## To install ELRepo for RHEL-9
yum install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm

## To install ELRepo for RHEL-8
yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm

## To install kernel
yum --enablerepo=elrepo-kernel install  kernel-lt-devel kernel-lt -y

## Set the default start
grub2-set-default 0

## Reboot
reboot

## Remove old kernel
rpm -qa | grep kernel
yum remove kernel-version -y
