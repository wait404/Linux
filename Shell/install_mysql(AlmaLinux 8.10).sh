#!/usr/bin/env bash

local_path=/usr/local
mysql_path=/usr/local/mysql

[ $EUID -ne 0 ] && echo "Please run as root." && exit 1

source /etc/os-release
if [[ $ID == 'almalinux' && $VERSION_ID == '8.10' ]]
then
    yum install epel-release -y
    yum install libaio ncurses-compat-libs gperftools-libs -y
    ln -sf /usr/lib64/libtcmalloc.so.4 /usr/lib64/libtcmalloc.so
else
    echo "The script only support AlmaLinux 8.10!"
    exit 1
fi

while true
do
    read -s -p "Please input the password:" mysql_password
    if [ -z ${mysql_password} ]
    then
        echo && continue
    else
        echo && break
    fi
done

egrep mysql /etc/group &> /dev/null
if [ $? -ne 0 ]
then
    groupadd mysql
fi

egrep mysql /etc/passwd &> /dev/null
if [ $? -ne 0 ]
then
    useradd -s `which nologin` -M -g mysql mysql
fi

wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.44-linux-glibc2.12-x86_64.tar.gz -O ${local_path}/mysql.tar.gz
tar -zxvf ${local_path}/mysql.tar.gz -C ${local_path}
rm ${local_path}/mysql.tar.gz -rf
mv ${local_path}/mysql-5.7.44-linux-glibc2.12-x86_64 ${mysql_path}
mkdir ${mysql_path}/data
chown -R mysql:mysql ${mysql_path}/data
chgrp -R mysql ${mysql_path}

if [ -f /etc/ld.so.conf.d/mysql.conf ]
then
    mv /etc/ld.so.conf.d/mysql.conf /etc/ld.so.conf.d/mysql.conf.bak
fi
cat > /etc/ld.so.conf.d/mysql.conf <<EOF
${mysql_path}/lib
EOF

if [ -f /etc/my.cnf ]
then
    mv /etc/my.cnf /etc/my.cnf.bak
fi
cat > /etc/my.cnf <<EOF
[client]
#password = your_password
port = 3306
socket = /tmp/mysql.sock
default-character-set = utf8mb4
ssl-ca = ${mysql_path}/data/ca.pem
ssl-cert = ${mysql_path}/data/client-cert.pem
ssl-key = ${mysql_path}/data/client-key.pem
[mysqld]
port = 3306
socket = /tmp/mysql.sock
character-set-server = utf8mb4
collation-server = utf8mb4_general_ci
require_secure_transport = OFF
bind-address = 0.0.0.0
datadir = ${mysql_path}/data
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 8M
tmp_table_size = 16M
performance_schema_max_table_instances = 500
explicit_defaults_for_timestamp = true
#skip-networking
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535
log-bin = mysql-bin
binlog_format = mixed
server-id = 1
expire_logs_days = 10
early-plugin-load = ""
default_storage_engine = InnoDB
innodb_file_per_table = 1
innodb_data_home_dir = ${mysql_path}/data
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${mysql_path}/data
innodb_buffer_pool_size = 16M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50
ssl-ca = ${mysql_path}/data/ca.pem
ssl-cert = ${mysql_path}/data/server-cert.pem
ssl-key = ${mysql_path}/data/server-key.pem
[mysqldump]
quick
max_allowed_packet = 16M
[mysql]
no-auto-rehash
default-character-set = utf8mb4
[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M
[mysqlhotcopy]
interactive-timeout
[mysqld_safe]
malloc-lib = /usr/lib64/libtcmalloc.so
EOF

${mysql_path}/bin/mysqld --initialize-insecure --basedir=${mysql_path} --datadir=${mysql_path}/data --user=mysql
${mysql_path}/bin/mysql_ssl_rsa_setup
chown mysql:mysql ${mysql_path}/data/*.pem

\cp ${mysql_path}/support-files/mysql.server /etc/init.d/mysql

ln -sf ${mysql_path}/bin/mysqladmin /usr/bin/mysqladmin
ln -sf ${mysql_path}/bin/mysql /usr/bin/mysql
ln -sf ${mysql_path}/bin/mysqldump /usr/bin/mysqldump
ln -sf ${mysql_path}/bin/myisamchk /usr/bin/myisamchk
ln -sf ${mysql_path}/bin/mysqld_safe /usr/bin/mysqld_safe
ln -sf ${mysql_path}/bin/mysqlcheck /usr/bin/mysqlcheck

/etc/init.d/mysql restart
mysqladmin -u root password "${mysql_password}"

pidof mysqld &> /dev/null
if [ $? -eq 0 ]
then
    echo "Success,password is ${mysql_password}."
    chkconfig --add mysql
else
    echo "Fail,please check!"
    exit 1
fi
