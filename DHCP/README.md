### 配置文件中的声明
声明|功能
:---:|:---:
shared-network 名称 {...}|定义超级作用域
subnet 网络号 netmask 子网掩码 {...}|定义作用域（或IP子网）
range 起始IP地址 终止IP地址|定义作用域（或IP子网）范围
host 主机名 {...}|定义保留地址
grop {...}|定义一组参数
### 配置文件中的参数
参数|功能
:---:|:---:
ddns-update-style 类型|定义所支持的DNS动态更新类型（必选）
allow/ignore client-updates|允许/忽略客户端更新DNS记录
default-lease-time 数字|指定默认的租约期限
max-lease-time 数字|指定最大租约期限
hardware 硬件类型 MAC地址|指定网卡河口类型和MAC地址
server-name 主机名|通知DHCP客户端服务器的主机名
fixed-address IP地址|分配给客户端一个固定的IP地址
### 配置文件中的选项
选项|功能
:---:|:---:
subnet-mask 子网掩码|为客户端指定子网掩码
domian-name “域名”|为客户端指定DNS域名
domain-name-srvers IP地址|为客户端指定DNS服务器的IP地址
host-name “主机名”|为客户端指定主机名
routers IP地址|为客户端指定默认网关
broadcast-address 广播地址|为客户端指定广播地址
netbios-name-servers IP地址|为客户端指定WINS服务器的IP地址
netbios-node type 节点类型|为客户端指定节点类型
ntp-server IP地址|为客户端指定网络时间服务器的IP地址
nis-server IP地址|为客户端指定NIS域服务器的地址
nis-domian “名称”|为客户端指定所属的NIS域的名称
time-offset 偏移差|为客户端指定与格林尼治时间的偏移差
