#!/usr/bin/env bash

local_path=/usr/local/src
python3_path=/usr/local/python3
python3_file=https://www.python.org/ftp/python/3.8.8/Python-3.8.8.tgz

[ $EUID -ne 0 ] && echo "Please run as root." && exit 1

if command -v yum &> /dev/null
then
    yum install -y wget zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libffi-devel libpcap-devel xz-devel
else
    echo "The script only support CentOS!"
    exit 1
fi

wget ${python3_file} -O ${local_path}/Python3.tgz
tar -zxf ${local_path}/Python3.tgz -C ${local_path}
cd ${local_path}/Python-3.8.8
./configure --prefix=${python3_path}
make && make install

ln -sf ${python3_path}/bin/python3 /usr/bin/python3
ln -sf ${python3_path}/bin/pip3 /usr/bin/pip3

rm -rf ${local_path}/{Python3.tgz,Python-3.8.8}

echo "Python3 has been installed."
