#!/bin/bash
# install packages
yum install -y deltarpm epel-release
yum -y update
yum -y install python-pip wget bzip2 tree man
pip install --upgrade pip
pip install requests
pip install simplejson
pip install pyzabbix

# run zabbix Agent
rpm -Uvh https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
yum install -y zabbix-agent zabbix-sender pip
ZABBIX_AGENT_CONF="/etc/zabbix/zabbix_agentd.conf";
ZABBIX_SERVER="192.168.0.50";
echo "ListenPort=10050" >> $ZABBIX_AGENT_CONF
echo "Server=$ZABBIX_SERVER" >> $ZABBIX_AGENT_CONF;
echo "ServerActive=$ZABBIX_SERVER" >> $ZABBIX_AGENT_CONF;
systemctl start zabbix-agent
systemctl enable zabbix-agent

# run python's script
python zabbix.py
