### 配置监听地址与控制端口
选项|说明
:---:|:---:
listen_address=IP address|设置服务器IP。
listen_port=XX|设置服务器控制端口，默认值为21。
### 设置FTP模式与数据端口
选项|说明
:---:|:---:
connect_from_port_20=YSE/NO|设置以port模式进行数据传输时使用20端口。
pasv_address=IP address|设置vsftpd服务器使用PASV模式时使用的IP地址，默认值未设置。
pasv_enable=YES/NO|设置是否允许使用PASV模式，默认值为YES。
pasv_min_port=XX|设置PASV模式可以使用的最小端口，默认值为0，即未限制，可设置为不小于1024不大于65535的数值。
pasv_max_port=XX|设置PASV模式可以使用的最大端口，默认值为0，即未限制，可设置为不小于1024不大于65535的数值。
pasv_promiscuous=YES/NO|设置是否支持用户的台式机作为客户控制端，让数据在两台服务器之间传输。
port_enable=YES/NO|设置是否允许使用主动传输模式，默认值为YES.
### 配置ASCII模式
选项|说明
:---:|:---:
ascii_download_enable=YES/NO|设置是否允许使用ASCII模式下载，默认值为NO。
ascii_upload_enable=YES/NO|设置是否允许使用ASCII模式上传，默认值为NO。
### 配置超时选项
选项|说明
:---:|:---:
data_connection_timeout=XXX|定义数据传输过程中被阻塞的最长时间（以秒为单位），一旦超出这个时间，客户端的连接将被关闭，默认值是300。
idle_session_timeout=XXX|定义客户端闲置的最长时间（以秒为单位），一旦超出这个时间，客户端的连接将被qiangz强制关闭，默认值是300。
connect_timeout=XXX|设置客户端尝试连接vsftpd命令通道的超时时间。
### 配置负载控制
选项|说明
:---:|:---:
anon_max_rate=XXXX|设置匿名用户的最大传输速率，单位是B/s。
local_max_rate=XXXX|设置本地用户的最大传输速率，单位是B/s。
### 配置匿名用户
选项|说明
:---:|:---:
anonymous_enable=YES/NO|设置是否允许匿名用户登录，默认值为YES。
anon_mkdir_write_enable=YES/NO|设置是否允许匿名用户在具备写权限的目录中创建新目录，默认值为NO。
anon_root=/PATH|设置匿名用户登录vsftpd后，将目录切换到指定目录，默认值未设置。
anon_upload_enable=YES/NO|设置是否允许匿名用户在具备写权限的目录中上传文件，默认值为NO。
anon_world_readable_only=YES/NO|设置是否允许匿名用户只具备下载权限。
ftp_username=USER|设置指定用户的/home目录为匿名用户访问FTP服务器时的根目录，默认值为ftp。
no_anon_password=YES/NO|设置是否允许匿名用户无需输入密码，默认值为NO。
secure_email_list_enable=YES/NO|设置是否允许匿名只能通过特定的E-mail作为密码访问vsftpd服务，默认值为NO。
### 配置本地用户及目录
选项|说明
:---:|:---:
local_enable=YES/NO|设置是否允许本地用户登录，默认值为YES。
local_root=/PATH|设置本地用户登录vsftpd后，将目录切换到指定目录，默认值未设置。
local_umask=XXX|设置文件创建的掩码，默认值为022，即其他用户具有只读属性。
chmod_enable=YES/NO|设置是否允许以本地用户登陆的客户通过chmod命令修改文件的权限。
chroot_local_user=YES/NO|设置是否本地用户只能访问其/home目录。
chroot_list_enable=YES/NO|设置是否允许例外用户切换到其/home目录之外的目录，默认文件为/etc/vsftpd/chroot_list。
### 配置虚拟用户
选项|说明
:---:|:---:
guest_enable=YES/NO|设置是否所有非匿名用户都被映射为一个特定的本地用户，该用户通过guest_username指定，默认值为NO。
guest_username=USER|设置虚拟用户映射到的本地用户，默认值为ftp。
### 配置用户登录控制
选项|说明
:---:|:---:
banner_file=/FILE|设置客户端登录后，服务器显示在客户端的信息，该信息保存在banner_file指定的文件中。
cmds_allowed=COMMAND|设置客户端登录vsftpd服务器后，客户端可以执行的命令集合，以“,”为分隔符，默认值未设置。
ftp_banner=TEXT|设置客户端登录vsftp服务器后显示的欢迎信息或其它相关信息，若已设置banner_file，则be本命令会被忽略，默认值未设置。
userlist_enable=YES/NO|设置userlist_deny配置是否生效。
userlist_deny=YES/NO|设置是否仅禁止user_list名单中的用户登录或仅允许user_list名单中的用户登录。
### 配置目录访问控制
选项|说明
:---:|:---:
dirlist_enable=YES/NO|设置是否允许用户列目录，默认值为YES。
dirmessage_enable=YES/NO|设置是否显示目录切换信息。
message_file=/FILE|设置目录切换时显示信息的文件，默认值为.message。
force_dot_file=YES/NO|设置是否显示以“.”开头的文件，默认值为NO。
hide_ids=YES/NO|设置是否隐藏文件的所有者和组信息，匿名用户看到的文件所有者和组全部变成ftp。
### 配置文件操作控制
选项|说明
:---:|:---:
downdownload_enable=YES/NO|设置是否允许下载，默认值为YES
chown_uploads=YES/NO|设置是否将所有匿名用户上传的文件的拥有者设置为chown_username指定的用户，默认值为NO。
chown_username=USER|设置匿名用户上传的文件的拥有者，默认值为root。
writ_enable=YES/NO|设置是否允许客户端登录后允许使用DELE（删除文件）、RNFR（重命名）、和STOR（断点续传）命令。
### 配置新增文件权限设置
选项|说明
:---:|:---:
anon_umask=XXX|设置匿名用户新增文件的umask数值，默认值为077。
file_open_mode=XXX|设置上传文件的权限，与chmod所使用的数值相同。
local_umask=XXX|设置本地用户新增文件时的umask数值，默认值为077。
### 日志设置
选项|说明
:---:|:---:
dual_log_enable=YES/NO|设置是否生成日志文件，分别为/var/log/xferlog和/var/logrolated/vsftpd.log，var/log/xferlog可用于标准工具分析，/var/logrolated/vsftpd.log是vsftpd类型日志。
log_ftp_protocol=YES/NO|设置是否记录所有的FTP命令信息，默认值为NO。
syslog_enable=YES/NO|设置是否将日志传输至syslogddeamon，由syslogd配置文件决定存储位置，默认值为NO。
xferlog_enable=YES/NO|设置是否详细记录上传和下载操作并写入/var/logrolated/vsftpd.log，默认值为NO。
xferlog_std_format=YES/NO|设置是否以标准xferlog格式书写传输日志文件，日志文件默认为/var/log/xferlog。
### 限制服务器连接数
选项|说明
:---:|:---:
max_clients=XX|设置FTP同一时刻的最大连接数，默认值为0，即不限制最大连接数。
max_per_ip=XX|设置每个IP的最大连接数，默认值为0，即不限制最大连接数。
