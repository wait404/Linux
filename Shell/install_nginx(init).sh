#!/usr/bin/env bash

src_path=/usr/local/src
nginx_init=/etc/init.d/nginx

[ $EUID -ne 0 ] && echo "Please run as root." && exit 1

if command -v apt-get &> /dev/null
then
    apt-get update
    apt-get install curl gcc git libpcre3 libpcre3-dev make openssl libssl-dev zlib1g zlib1g-dev -y
elif command -v yum &> /dev/null
then
    yum install curl gcc git pcre pcre-devel make openssl openssl-devel zlib zlib-devel -y
else
    echo "Please check your OS!"
    exit 1
fi

read -p "Please input nginx version:" nginx_version
if curl -Is http://nginx.org/download/nginx-${nginx_version}.tar.gz | grep 404 &> /dev/null
then
    echo "The nginx version is error!"
    exit 1
fi

read -p "Please input nginx user(default user is www):" nginx_user
[ -z ${nginx_user} ] && nginx_user=www
id ${nginx_user} &> /dev/null
if [ $? -ne 0 ]
then
    groupadd ${nginx_user}
    useradd -M -s `which nologin` -g ${nginx_user} ${nginx_user}
fi

read -e -p "Please input nginx path(default path is /usr/local/nginx):" nginx_path
[ -z ${nginx_path} ] && nginx_path=/usr/local/nginx
if [ -f ${nginx_path} ]
then
    echo "Couldn't create directory,file exists!"
    exit 1
elif [ ! -d ${nginx_path} ]
then
    mkdir -p ${nginx_path}
fi
    
function Install_http_substitutions()
{
    git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git ${src_path}/ngx_http_substitutions_filter_module
}
function Install_brotli()
{
    git clone https://github.com/google/ngx_brotli.git ${src_path}/ngx_brotli
    cd ${src_path}/ngx_brotli
    git submodule update --init
}
function Install_openssl()
{
    curl -sSL https://www.openssl.org/source/old/1.1.1/openssl-1.1.1g.tar.gz -o ${src_path}/openssl-1.1.1g.tar.gz
    tar -zxf ${src_path}/openssl-1.1.1g.tar.gz -C ${src_path}
    mv ${src_path}/openssl-1.1.1g ${src_path}/openssl
}
function Install_nginx()
{
    curl -sSL http://nginx.org/download/nginx-${nginx_version}.tar.gz -o ${src_path}/nginx-${nginx_version}.tar.gz
    tar -zxf ${src_path}/nginx-${nginx_version}.tar.gz -C ${src_path}
    cd ${src_path}/nginx-${nginx_version}
    ./configure --user=${nginx_user} --group=${nginx_user} --prefix=${nginx_path} --with-http_stub_status_module --with-http_realip_module --with-http_ssl_module --with-http_v2_module --with-http_gzip_static_module --with-http_sub_module --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --add-module=../ngx_brotli --add-module=../ngx_http_substitutions_filter_module --with-openssl=../openssl
    make -j `cat /proc/cpuinfo | grep -c processor` && make install
    if [ $? -eq 0 ]
    then
        echo "Success!"
    else
        echo "Fail!"
        exit 1
    fi
}
function Install_nginx_init()
{
    if [ ! -f ${nginx_init} ]
    then
        cat > ${nginx_init} <<EOF
#! /bin/sh

### BEGIN INIT INFO
# Provides:          nginx
# Required-Start:    \$local_fs \$network \$remote_fs
# Required-Stop:     \$local_fs \$network \$remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the nginx web server
# Description:       starts nginx using start-stop-daemon
### END INIT INFO

NGINX_BIN='${nginx_path}/sbin/nginx'
CONFIG='${nginx_path}/conf/nginx.conf'

case "\$1" in
    start)
        echo -n "Starting nginx... "

        PID=\$(ps -ef | grep "\$NGINX_BIN" | grep -v grep | awk '{print \$2}')
        if [ "\$PID" != "" ]; then
            echo "nginx (pid \$PID) already running."
            exit 1
        fi

        \$NGINX_BIN -c \$CONFIG

        if [ "\$?" != 0 ]; then
            echo " failed"
            exit 1
        else
            echo " done"
        fi
        ;;

    stop)
        echo -n "Stoping nginx... "

        PID=\$(ps -ef | grep "\$NGINX_BIN" | grep -v grep | awk '{print \$2}')
        if [ "\$PID" = "" ]; then
            echo "nginx is not running."
            exit 1
        fi

        \$NGINX_BIN -s stop

        if [ "\$?" != 0 ] ; then
            echo " failed. Use force-quit"
            \$0 force-quit
        else
            echo " done"
        fi
        ;;

    status)
        PID=\$(ps -ef | grep "\$NGINX_BIN" | grep -v grep | awk '{print \$2}')
        if [ "\$PID" != "" ]; then
            echo "nginx (pid \$PID) is running..."
        else
            echo "nginx is stopped."
            exit 0
        fi
        ;;

    force-quit|kill)
        echo -n "Terminating nginx... "

        PID=\$(ps -ef | grep "\$NGINX_BIN" | grep -v grep | awk '{print \$2}')
        if [ "\$PID" = "" ]; then
            echo "nginx is is stopped."
            exit 1
        fi

        kill \$PID

        if [ "\$?" != 0 ]; then
            echo " failed"
            exit 1
        else
            echo " done"
        fi
        ;;

    restart)
        \$0 stop
        sleep 1
        \$0 start
        ;;

    reload)
        echo -n "Reload nginx... "

        PID=\$(ps -ef | grep "\$NGINX_BIN" | grep -v grep | awk '{print \$2}')
        if [ "\$PID" != "" ]; then
            \$NGINX_BIN -s reload
            echo " done"
        else
            echo "nginx is not running, can't reload."
            exit 1
        fi
        ;;

    configtest)
        echo -n "Test nginx configure files... "

        \$NGINX_BIN -t
        ;;

    *)
        echo "Usage: \$0 {start|stop|restart|reload|status|configtest|force-quit|kill}"
        exit 1
        ;;

esac
EOF
        chmod +x ${nginx_init}
        ln -sf ${nginx_path}/sbin/nginx /usr/bin/nginx
    fi
}
Clean_files()
{
    cd ${src_path}
    rm -rf ${src_path}/openssl* ${src_path}/ngx_brotli ${src_path}/ngx_http_substitutions_filter_module ${src_path}/nginx-${nginx_version}*
    if [ -f ${nginx_path}/sbin/nginx.old ]
    then
        rm -f ${nginx_path}/sbin/nginx.old
    fi
}

Install_http_substitutions
Install_brotli
Install_openssl
Install_nginx
Install_nginx_init
Clean_files
${nginx_init} restart
echo "The nginx version is:"
${nginx_path}/sbin/nginx -v
