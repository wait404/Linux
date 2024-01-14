#!/usr/bin/env bash

src_path=/usr/local/src
nginx_service=/etc/systemd/system/nginx.service

[ $EUID -ne 0 ] && echo "Please run as root." && exit 1

if command -v apt-get &> /dev/null
then
    apt-get update
    apt-get install curl gcc git libbrotli-dev libxml2 libxml2-dev libxslt1.1 libxslt1-dev libpcre3 libpcre3-dev make openssl libssl-dev zlib1g zlib1g-dev -y
elif command -v yum &> /dev/null
then
    yum install curl gcc git perl brotli-devel libxml2 libxml2-devel libxslt libxslt-devel pcre pcre-devel make openssl openssl-devel zlib zlib-devel -y
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

function Install_brotli()
{
    git clone https://github.com/google/ngx_brotli.git ${src_path}/ngx_brotli
    cd ${src_path}/ngx_brotli
    git submodule update --init
}
function Install_http_substitutions()
{
    git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git ${src_path}/ngx_http_substitutions_filter_module
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
    ./configure --user=${nginx_user} --group=${nginx_user} --prefix=${nginx_path} --with-http_dav_module --with-http_stub_status_module --with-http_realip_module --with-http_ssl_module --with-http_v2_module --with-http_gzip_static_module --with-http_sub_module --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-openssl=../openssl --add-module=../ngx_brotli --add-module=../ngx_http_substitutions_filter_module
    make -j `cat /proc/cpuinfo | grep -c processor` && make install
    if [ $? -eq 0 ]
    then
        echo "Success!"
    else
        echo "Fail!"
        exit 1
    fi
}
function Install_nginx_service()
{
    if [ ! -f ${nginx_service} ]
    then
        cat > ${nginx_service} <<EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=${nginx_path}/logs/nginx.pid
ExecStart=${nginx_path}/sbin/nginx -c ${nginx_path}/conf/nginx.conf
ExecReload=${nginx_path}/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=false

[Install]
WantedBy=multi-user.target
EOF
        chmod +x ${nginx_service}
        systemctl daemon-reload
        systemctl enable nginx
        ln -sf ${nginx_path}/sbin/nginx /usr/bin/nginx
    fi
}

function Clean_files()
{
    cd ${src_path}
    rm -rf ${src_path}/openssl* ${src_path}/nginx-dav-ext-module ${src_path}/ngx_brotli ${src_path}/ngx_http_substitutions_filter_module ${src_path}/nginx-${nginx_version}*
    if [ -f ${nginx_path}/sbin/nginx.old ]
    then
        rm -f ${nginx_path}/sbin/nginx.old
    fi
}

Install_brotli
Install_http_substitutions
Install_openssl
Install_nginx
Install_nginx_service
Clean_files
systemctl restart nginx
echo "The nginx version is:"
${nginx_path}/sbin/nginx -v
