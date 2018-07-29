#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Color
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
#Info
clear
echo
echo "#############################################################"
echo "#                             DNS                           #"
echo "#############################################################"
echo
#Install bind and bind-chroot
Install_bind()
{
    yum install bind bind-chroot -y > /dev/null
    \cp -pr /etc/named* /var/named/chroot/etc/
    \cp -pr /usr/share/doc/bind*/sample/var/named/* /var/named/chroot/var/named/
    if [ ! -d "/var/named/chroot/var/named/dynamic" ]
    then
        mkdir /var/named/chroot/var/named/dynamic
    fi
    touch /var/named/chroot/var/named/data/cache_dump.db
    touch /var/named/chroot/var/named/data/named_stats.txt
    touch /var/named/chroot/var/named/data/named_mem_stats.txt
    touch /var/named/chroot/var/named/data/named.run
    touch /var/named/chroot/var/named/dynamic/managed-keys.bind
    chmod -R 777 /var/named/chroot/var/named/data
    chmod -R 777 /var/named/chroot/var/named/dynamic
    chown -R root:named /var/named/chroot/
}
#Edit the conf
Edit_conf()
{
    sed -i 's/127.0.0.1;/any;/g' /var/named/chroot/etc/named.conf
    sed -i 's/localhost;/any;/g' /var/named/chroot/etc/named.conf
    sed -i 's/named.rfc1912.zones/named.zones/g' /var/named/chroot/etc/named.conf
}
Set_firewalld()
{
    firewall_state=`firewall-cmd --state`
    check_dns=`firewall-cmd --list-services | grep -i dns | wc -l`
    check_53udp=`firewall-cmd --list-ports | grep -i 53/udp | wc -l`
    if [[ ${firewall_state} == "running" ]]
    then
        if [[ ${check_dns} -ne 0 || ${check_53udp} -ne 0 ]]
        then
            echo -e "${green}The port has been opened!${plain}"
        else
            firewall-cmd --zone=public --permanent --add-service=dns > /dev/null
            firewall-cmd --reload > /dev/null
            echo -e "${green}The port is successfully opened!${plain}"
        fi
    else
        echo -e "${yellow}Please check the firewalld status!${plain}"
    fi
}                                                               
#Disable selinux
Disable_selinux()
{
    enforce_info=`getenforce`
    if [[ ${enforce_info} == "Enforcing" ]]
    then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
    fi
}
#check ip
function check_ip()
{
    local ip_addr=$1
    valid_check=`echo ${ip_addr}|awk -F. '$1<=255&&$2<=255&&$3<=255&&$4<=255{print "yes"}'`
    if echo ${ip_addr} | grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" >/dev/null
    then
        if [[ ${valid_check} == "yes" ]]
        then
            return 0
        else
            echo -e "${yellow}The ip address is not available!${plain}"
            return 1
        fi
    else
        echo -e "${yellow}The ip address is not available!${plain}"
        return 1
    fi
}
#Set the conf
Master_dns()
{
    read -p "Please input the domain name:" domain_name
    while true
    do
        read -p "Please input the ip area(example 192.168.0.0.):" ip_addr
        check_ip ${ip_addr}
        [ $? -eq 0 ] && break
    done
    ip_addr_head=`echo ${ip_addr} | cut -d . -f -2`
    #Edit the name.zones
    echo "zone \"${domain_name}\" IN {" >> /var/named/chroot/etc/named.zones
    echo "    type master;" >> /var/named/chroot/etc/named.zones
    echo "    file \"${domain_name}.zone\";" >> /var/named/chroot/etc/named.zones
    echo "    allow-update { none; };" >> /var/named/chroot/etc/named.zones
    echo "};" >> /var/named/chroot/etc/named.zones
    echo "" >> /var/named/chroot/etc/named.zones
    echo "zone \"`echo ${ip_addr_head} | awk -F . '{print $2"."$1}'`.in-addr.arpa\" IN {" >> /var/named/chroot/etc/named.zones
    echo "    type master;" >> /var/named/chroot/etc/named.zones
    echo "    file \"${ip_addr_head}.zone\";" >> /var/named/chroot/etc/named.zones
    echo "    allow-update { none; };" >> /var/named/chroot/etc/named.zones
    echo "};" >> /var/named/chroot/etc/named.zones
    #Edit the ${domain_name}.zone
    echo "\$TTL 1D" >> /var/named/chroot/var/named/${domain_name}.zone
    echo "@   IN SOA  ${domain_name}. root.${domain_name}. (" >> /var/named/chroot/var/named/${domain_name}.zone
    echo "                    0   ; serial" >> /var/named/chroot/var/named/${domain_name}.zone
    echo "                    1D  ; refresh" >> /var/named/chroot/var/named/${domain_name}.zone
    echo "                    1H  ; retry" >> /var/named/chroot/var/named/${domain_name}.zone
    echo "                    1W  ; expire" >> /var/named/chroot/var/named/${domain_name}.zone
    echo "                    3H )    ; minimum" >> /var/named/chroot/var/named/${domain_name}.zone
    echo "" >> /var/named/chroot/var/named/${domain_name}.zone
    #Edit the ${ip_addr_head}.zone
    echo "\$TTL 1D" >> /var/named/chroot/var/named/${ip_addr_head}.zone
    echo "@   IN SOA  ${domain_name}. root.${domain_name}. (" >> /var/named/chroot/var/named/${ip_addr_head}.zone
    echo "                    0   ; serial" >> /var/named/chroot/var/named/${ip_addr_head}.zone
    echo "                    1D  ; refresh" >> /var/named/chroot/var/named/${ip_addr_head}.zone
    echo "                    1H  ; retry" >> /var/named/chroot/var/named/${ip_addr_head}.zone
    echo "                    1W  ; expire" >> /var/named/chroot/var/named/${ip_addr_head}.zone
    echo "                    3H )    ; minimum" >> /var/named/chroot/var/named/${ip_addr_head}.zone
    echo "" >> /var/named/chroot/var/named/${ip_addr_head}.zone
    #Check resolve type
    function check_resolve_type()
    {
        local resolve_type=$1
        resolve_type_array=(a A cname CNAME mx MX ns NS)
        if echo "${resolve_type_array[@]}" | grep -w "${resolve_type}" > /dev/null
        then
            return 0
        else
            echo -e "${red}Your resolve is error,please retry!${plain}"
            return 1
        fi
    }
    #Add resolve
    while ((1))
    do
        while true
        do
            read -p "Please input resolve type:" resolve_type
            check_resolve_type $resolve_type
            [ $? -eq 0 ] && break
        done
        case ${resolve_type} in
            A|a)
                read -p "Please input subdomain:" sub_domain_name
                while true
                do
                    read -p "Please input ip address:" ip_addr
                    check_ip ${ip_addr}
                    [ $? -eq 0 ] && break
                done
                echo "${sub_domain_name}     IN     A       ${ip_addr}" >> /var/named/chroot/var/named/${domain_name}.zone
                echo "`echo ${ip_addr} | cut -d . -f 3- | awk -F . '{print $2"."$1}'`     IN     PTR     ${sub_domain_name}.${domain_name}." >> /var/named/chroot/var/named/${ip_addr_head}.zone
                ;;
            CNAME|cname)
                read -p "Please input subdomain:" sub_domain_name
                read -p "Please input cname domain:" cname_domain
                echo "${sub_domain_name}     IN     CNAME   ${cname_domain}" >> /var/named/chroot/var/named/${domain_name}.zone
                ;;
            MX|mx)
                read -p "Please input subdomain:" sub_domain_name
                read -p "Please Input MX value:" mx_value
                echo "@       IN     MX  ${mx_value}  ${sub_domain_name}.${domain_name}." >> /var/named/chroot/var/named/${domain_name}.zone
                echo "@       IN     MX  ${mx_value}  ${sub_domain_name}.${domain_name}." >> /var/named/chroot/var/named/${ip_addr_head}.zone
                ;;
            NS|ns)
                read -p "Please input subdomain:" sub_domain_name
                while true
                do
                    read -p "Please input ip address:" ip_addr
                    check_ip ${ip_addr}
                    [ $? -eq 0 ] && break
                done
                echo "@       IN     NS      ${sub_domain_name}.${domain_name}." >> /var/named/chroot/var/named/${domain_name}.zone
                echo "${sub_domain_name}     IN     A       ${ip_addr}" >> /var/named/chroot/var/named/${domain_name}.zone
                echo "@       IN     NS      ${sub_domain_name}.${domain_name}." >> /var/named/chroot/var/named/${ip_addr_head}.zone
                echo "`echo ${ip_addr} | cut -d . -f 3- | awk -F . '{print $2"."$1}'`     IN     PTR     ${sub_domain_name}.${domain_name}." >> /var/named/chroot/var/named/${ip_addr_head}.zone
                ;;
        esac
        read -p "Would you want to add another resolve(Y/N):" choise_char
        case ${choise_char} in
            Y|y)
                continue
                ;;
            N|n)
                break
                ;;
            *)
                echo "${red}Your choise is erroar!${plain}"
                ;;
        esac
    done
}
#Slave dns
Slave_dns()
{
    mkdir /var/named/chroot/etc/slaves
    chown root:named /var/named/chroot/etc/slaves
    read -p "please input the master domain name:" domain_name
    while true
    do
        read -p "Please input ip address:" ip_addr
        check_ip ${ip_addr}
        [ $? -eq 0 ] && break
    done
    ip_addr_head=`echo ${ip_addr} | cut -d . -f -2`
    #Edit the name.zones
    echo "zone \"${domain_name}\" IN {" >> /var/named/chroot/etc/named.zones
    echo "    type slave;" >> /var/named/chroot/etc/named.zones
    echo "    file \"slaves/${domain_name}.zone\";" >> /var/named/chroot/etc/named.zones
    echo "    masters { ${ip_addr}; };" >> /var/named/chroot/etc/named.zones
    echo "};" >> /var/named/chroot/etc/named.zones
    echo "" >> /var/named/chroot/etc/named.zones
    echo "zone \"`echo ${ip_addr_head} | awk -F . '{print $2"."$1}'`.in-addr.arpa\" IN {" >> /var/named/chroot/etc/named.zones
    echo "    type slave;" >> /var/named/chroot/etc/named.zones
    echo "    file \"slaves/${ip_addr_head}.zone\";" >> /var/named/chroot/etc/named.zones
    echo "    masters { ${ip_addr}; };" >> /var/named/chroot/etc/named.zones
    echo "};" >> /var/named/chroot/etc/named.zones
}
#Start service
Start_service()
{
    systemctl start named
    systemctl enable named
    systemctl start named-chroot
    systemctl enable named-chroot
    echo -e "${green}Install complated.${plain}"
}
read -p "Which dns service would you want to instll(master/slave):" dns_type
case ${dns_type} in
    master)
        Install_bind
        Edit_conf
        Set_firewalld
        Disable_selinux
        Master_dns
        Start_service
        exit 0
        ;;
    slave)
        Install_bind
        Edit_conf
        Set_firewalld
        Disable_selinux
        Slave_dns
        Start_service
        exit 0
        ;;
    *)
        echo -e "${red}Input error!${plain}"
        exit 1
        ;;
esac
