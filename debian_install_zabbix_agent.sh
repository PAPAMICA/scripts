#!/usr/bin/env bash

clear
tput setaf 7; read -p "Entrez le nom du serveur : " server_name
tput setaf 7; read -p "Entrez l'ip du serveur Zabbix : " server_ip
#tput setaf 2; dpkg -i zabbix-release_4.0-3+stretch_all.deb

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

clear
tput bold; tput setaf 7; echo "STATUS DU SERVICE AGENT-ZABBIX : "
tput setaf 3; echo ""
systemctl status zabbix-agent
tput setaf 3; echo ""
tput bold; tput setaf 7; echo "-------------------------------------------------"
tput bold; tput setaf 7; echo "             => AGENT ZABBIX OK <="
tput setaf 7; echo ""
tput bold; tput setaf 6; echo "                By PAPAMICA"
tput bold; tput setaf 6; echo "                Labo-Tech.fr"
tput bold; tput setaf 7; echo "-------------------------------------------------"
tput setaf 2; echo ""

