#!/usr/bin/env bash

src_path=/usr/local/src
nginx_service=/etc/systemd/system/nginx.service

[ $EUID -ne 0 ] && echo "Please run as root." && exit 1

if command -v apt-get &> /dev/null
then
    apt-get update
    apt-get install -y cmake curl g++ gcc git libbrotli-dev libpcre2-8-0 libpcre2-dev libssl-dev libxml2 libxml2-dev libxslt1.1 libxslt1-dev make ninja-build perl openssl zlib1g zlib1g-dev
elif command -v yum &> /dev/null
then
    yum install -y brotli-devel cmake curl gcc gcc-c++ git libxml2 libxml2-devel libxslt libxslt-devel make ninja-build pcre pcre-devel perl openssl openssl-devel zlib zlib-devel 
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

function Install_openssl()
{
    curl -sSL https://github.com/openssl/openssl/releases/download/openssl-3.5.4/openssl-3.5.4.tar.gz -o ${src_path}/openssl-3.5.4.tar.gz
    tar -zxf ${src_path}/openssl-3.5.4.tar.gz -C ${src_path}
    mv ${src_path}/openssl-3.5.4 ${src_path}/openssl
}
function Install_headers_more_nginx()
{
    git clone https://github.com/openresty/headers-more-nginx-module.git ${src_path}/headers-more-nginx-module
}
function Install_dav_ext()
{
    git clone https://github.com/arut/nginx-dav-ext-module.git ${src_path}/nginx-dav-ext-module
}
function Install_brotli()
{
    git clone https://github.com/google/ngx_brotli.git ${src_path}/ngx_brotli
    cd ${src_path}/ngx_brotli
    git submodule update --init
}
function Install_fancyindex()
{
    git clone https://github.com/aperezdc/ngx-fancyindex.git ${src_path}/ngx-fancyindex
}
function Install_nginx()
{
    curl -sSL http://nginx.org/download/nginx-${nginx_version}.tar.gz -o ${src_path}/nginx-${nginx_version}.tar.gz
    tar -zxf ${src_path}/nginx-${nginx_version}.tar.gz -C ${src_path}
    cd ${src_path}/nginx-${nginx_version}
    ./configure --user=${nginx_user} --group=${nginx_user} --prefix=${nginx_path} --with-http_dav_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_realip_module --with-http_ssl_module --with-http_stub_status_module --with-http_v2_module --with-http_v3_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-openssl=../openssl  --add-module=../headers-more-nginx-module --add-module=../nginx-dav-ext-module --add-module=../ngx_brotli --add-module=../ngx-fancyindex
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
ExecStartPost=/usr/bin/sleep 1
ExecStart=${nginx_path}/sbin/nginx -c ${nginx_path}/conf/nginx.conf
ExecReload=${nginx_path}/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=false

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable nginx
        ln -sf ${nginx_path}/sbin/nginx /usr/bin/nginx
    fi
}

function Clean_files()
{
    rm -rf ${src_path}/openssl* ${src_path}/headers-more-nginx-module ${src_path}/ngx-fancyindex ${src_path}/nginx-dav-ext-module ${src_path}/ngx_brotli ${src_path}/ngx-fancyindex ${src_path}/nginx-${nginx_version}*
    if [ -f ${nginx_path}/sbin/nginx.old ]
    then
        rm -f ${nginx_path}/sbin/nginx.old
    fi
}

Install_openssl
Install_headers_more_nginx
Install_dav_ext
Install_brotli
Install_fancyindex
Install_nginx
Install_nginx_service
Clean_files
systemctl restart nginx.service
echo "The nginx version is:"
${nginx_path}/sbin/nginx -v
