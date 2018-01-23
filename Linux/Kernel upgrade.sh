#下载最新内核并解压
cd /usr/local/src/ && wget https://cdn.kernel.org/pub/linux/kernel/version/linux-version.tar.xz && tar -Jfxv linux-version.tar.xz && cd ./linux

#配置内核
#遍历选择所要编译的内核特性
make config
#配置所有可编译的内核特性
make allyesconfig
#能选的都选择为no、只有必须的都选择为yes
make allnoconfig
#菜单选择
make menuconfig
#KDE桌面环境下，并且安装了qt开发环境
make kconfig
#Gnome桌面环境，并且安装gtk开发环境
make gconfig
#在旧内核基础上修改
cp /boot/config-version-computing platform /usr/local/src/linux/.config
make oldconfig

#编译内核
make [-j#]

#安装内核模块
make modules_install

#安装内核
make install

#重启系统
reboot
