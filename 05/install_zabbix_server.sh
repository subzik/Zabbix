#!/bin/bash
yum update -y
yum install -y mariadb mariadb-server

/usr/bin/mysql_install_db --user=mysql

systemctl start mariadb
systemctl enable mariadb.service

mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin; grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix'; quit;"

#yum-config-manager --enable rhel-7-server-optional-rpms

yum install -y https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
yum install -y zabbix-server-mysql zabbix-web-mysql

zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -pzabbix zabbix

yum install  zabbix-server-mysql zabbix-web-mysql zabbix-agent zabbix-java-gateway zabbix-get -y

cat >> /etc/zabbix/zabbix_server.conf <<EOF

DBHost=localhost
DBPassword=zabbix
JavaGateway=127.0.0.1
JavaGatewayPort=10052
StartJavaPollers=5


EOF

systemctl start zabbix-server
systemctl enable zabbix-server
systemctl start zabbix-agent
systemctl enable zabbix-agent
systemctl start zabbix-java-gateway
systemctl enable zabbix-java-gateway


#set timezone
sed -i '/Europe/d'  /etc/httpd/conf.d/zabbix.conf
sed -i '/php_value memory_limit 128M/a php_value date.timezone Europe\/Minsk' /etc/httpd/conf.d/zabbix.conf
#starting
systemctl start httpd
