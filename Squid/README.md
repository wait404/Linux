### squid配置选项
配置选项|说明
:---:|:---:
http_port|定义监听客户连接请求的端口，默认端口为3128。
cache_mem|设置内存作为高速缓存。
cache_dir|用于指定硬盘缓冲区存储类型、存放目录、缓存空间大小（单位为M）、存放目录一级子目录个数、存放目录二级子目录个数。
maximum_object_size_in_memory|设置内存缓存最大文件。
maximum_object_size|设置磁盘缓存最大文件。
minimum_object_size|设置磁盘缓存最小文件。
cache_effective_user|使用缓存的有效用户。
cache_effective_group|使用缓存的有效用户组。
dns_nameservers|设置DNS服务器地址。
cache_access_log|设置访问记录的日志文件。
cache_log|设置缓存日志文件。
cache_store_log|设置网页缓存日志文件。
cache_swap_low|最低缓存百分比。
cache_swap_high|最高缓存百分比。
visible_hostname|设置当前主机名。
Vcache_mgr|管理员邮件地址。

### 访问控制列表选项
#### acl命令格式如下
acl 列表名称 列表类型 [-i] 列表值

ACL列表类型|说明
:---:|:---:
src ip-address/netmask|客户端源IP地址和子网掩码。
src addr1-addr4/netmask|客户端源IP地址范围。
dst ip-address/netmask|客户端目标IP地址和子网掩码。
myip ip-address/netmask|本地套接字IP地址。
srcdomain domain|源域名（客户机所属的域）。
dstdomain domain|目的域名（Internet中的服务器所属的域）。
srcdom_regex expression|对来源的URL做正则匹配表达式。
dstdom_regex expression|对目的URL做正则匹配表达式。
Time|指定时间。用法：acl aclname time [day-abbrevs] [h1:\m1-h2:m2] 其中，day-abbrevs可以为：S(Sunday)、M(Monday)、T(Tuesday)、W(Wednesday)、H(Thursday)、F(Friday)、A(Saturday)。
port|指定连接端口，如acl SSL_ports port 443。
proto|指定所使用的通信协议，如acl allowprotolist proto HTTP。
url_regex|设置URL规则匹配表达式。
url_path_regexp URL-path|设置略去协议和主机名的URL规则匹配表达式。
