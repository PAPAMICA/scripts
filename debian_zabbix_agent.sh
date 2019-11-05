#!/usr/bin/env bash

read -p "Entrez le nom du serveur : " server_name
read -p "Entrez l'ip du serveur Zabbix : " server_ip
dpkg -i zabbix-release_4.0-3+stretch_all.deb

apt-get update
apt-get install zabbix-agent -y

for file in /etc/zabbix/zabbix_agentd.conf
do
  echo "Traitement de $file ..."
  sed -i -e "s/Server=127.0.0.1/Server=$server_ip/g" "$file"
  sed -i -e "s/Hostname=Zabbix server/Hostname=$server_name/g" "$file"
done

service zabbix-agent start
systemctl enable zabbix-agent
systemctl start zabbix-agent

echo "-------------------------------------------------"
tput bold; tput setaf 7; echo "         => AGENT ZABBIX OK <="
echo "-------------------------------------------------"
systemctl restart zabbix-agent
