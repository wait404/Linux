#Download kernel
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/version/linux-headers-version-version-date_all.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/version/linux-headers-version-generic_version-date_amd64.deb
http://kernel.ubuntu.com/~kernel-ppa/mainline/version/linux-image-version-generic_version-date_amd64.deb

#Install
sudo dpkg -i *.deb

#reboot
reboot

#Remove old kernel
dpkg --get-selections| grep linux
sudo apt-get remove linux-image-version

#Remove deinstall
sudo dpkg -P linux-image-version
