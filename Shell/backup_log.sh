#!/bin/bash
mv ./website.log ./backup/website_`date +%Y%m%d -d -1day`.log
touch ./website.log
/usr/local/nginx/sbin/nginx -s reload
