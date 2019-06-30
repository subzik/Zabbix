#!/bin/bash
#install packages
yum install -y deltarpm epel-release
yum -y update
yum -y install java tomcat tomcat-webapps tomcat-admin-webappsnginx gcc make gcc-c++ kernel-devel kernel-headers perl wget bzip2 tree man

#nginx conf
yum -y install nginx
yum clean all
sed -i '/^#\|^$/d' /etc/nginx/nginx.conf #dell commented strings
sed -i '/\[::\]:80 default_server/s/^/#/' /etc/nginx/nginx.conf #comment ipv6 string
sed -i '/location \/ {/a \\t proxy_pass http://localhost:8080/sample/;' /etc/nginx/nginx.conf #add proxypass
systemctl start nginx

#tomcat
yum -y java tomcat tomcat-webapps tomcat-admin-webappsnginx #install tomcat
yum clean all
wget wget -P /usr/share/tomcat/webapps https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war #get, deploy warfile
wget wget -P /usr/share/tomcat/lib http://repo2.maven.org/maven2/org/apache/tomcat/tomcat-catalina-jmx-remote/7.0.76/tomcat-catalina-jmx-remote-7.0.76.jar
chown -R tomcat:tomcat /usr/share/tomcat


#add java JAVA_OPTS
cat >> /etc/tomcat/tomcat.conf <<EOF

JAVA_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=12345 -Dcom.sun.management.jmxremote.rmi.port=12346 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=192.168.0.51"

EOF

#setup JMX/RMI ports to server.xml
sed -i '/\^*.Server port="8005".*/a \  <Listener className\=\"org.apache.catalina.mbeans.JmxRemoteLifecycleListener" rmiRegistryPortPlatform\="8097" rmiServerPortPlatform\="8098" \/\>' /etc/tomcat/server.xml

systemctl start tomcat

#zabbix Agent
rpm -Uvh https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
yum install -y zabbix-agent zabbix-sender
ZABBIX_AGENT_CONF="/etc/zabbix/zabbix_agentd.conf";
ZABBIX_SERVER="192.168.0.50";
echo "ListenPort=10050" >> $ZABBIX_AGENT_CONF
echo "Server=$ZABBIX_SERVER" >> $ZABBIX_AGENT_CONF;
echo "ServerActive=$ZABBIX_SERVER" >> $ZABBIX_AGENT_CONF;

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

systemctl enable nginx
systemctl enable tomcat
