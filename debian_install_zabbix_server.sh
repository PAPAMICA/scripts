#!/bin/bash
clear
# Change these settings
read -p "Entrez le mot de passe pour Root pour MySQL : " MYSQL_ROOT_PASSWORD
read -p "Entrez le mot de passe pour la base de données Zabbix : " ZABBIX_DB_USER_PASSWORD
#read -p "Entrez l'adresse ip du serveur : " SERVER_IP
SERVER_IP=$(hostname -i)

apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce
systemctl enable docker
systemctl start docker

docker pull zabbix/zabbix-web-nginx-mysql
docker pull grafana/grafana
# Deploy a mysql container for zabbix to use.
docker run -d \
  --name="zabbix-mysql-database" \
  --restart=always \
  -p 3306:3306 \
  -e MYSQL_DATABASE=zabbix \
  -e MYSQL_USER=zabbix \
  -e MYSQL_PASSWORD=$ZABBIX_DB_USER_PASSWORD \
  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
  -v $HOME/volumes/mysql:/var/lib/mysql \
  mysql:5.7

# Deploy the zabbix-server application container
docker run -d \
  --name zabbix-server \
  --restart=always \
  -e DB_SERVER_HOST=localhost \
  -e MYSQL_USER="zabbix" \
  -e MYSQL_PASSWORD=$ZABBIX_DB_USER_PASSWORD \
  -v $HOME/volumes/zabbix/alertscripts:/usr/lib/zabbix/alertscripts \
  -v $HOME/volumes/zabbix/externalscripts:/usr/lib/zabbix/externalscripts \
  -v $HOME/volumes/zabbix/modules:/var/lib/zabbix/modules \
  -v $HOME/volumes/zabbix/enc:/var/lib/zabbix/enc \
  -v $HOME/volumes/zabbix/ssh_keys:/var/lib/zabbix/ssh_keys \
  -v $HOME/volumes/zabbix/ssl/certs:/var/lib/zabbix/ssl/certs \
  -v $HOME/volumes/zabbix/ssl/keys:/var/lib/zabbix/ssl/keys \
  -v $HOME/volumes/zabbix/ssl_ca:/var/lib/zabbix/ssl/ssl_ca \
  -v $HOME/volumes/zabbix/snmptraps:/var/lib/zabbix/snmptraps \
  -v $HOME/volumes/zabbix/mibs:/var/lib/zabbix/mibs \
  -p 10050:10050 \
  -p 10051:10051 \
  zabbix/zabbix-server-mysql:ubuntu-3.4-latest

# Deploy the webserver frontend.
docker run -d \
  --name zabbix-web-nginx \
  --restart=always \
  -e DB_SERVER_HOST="localhost" \
  -e MYSQL_USER="zabbix" \
  -e MYSQL_PASSWORD=$ZABBIX_DB_USER_PASSWORD \
  -e ZBX_SERVER_HOST=localhost \
  -e PHP_TZ="Europe/Paris" \
  -p 80:80 \
  -p443:443 \
  zabbix/zabbix-web-nginx-mysql:ubuntu-3.4-latest

#Deploy grafana
docker run -d --name=grafana -p 3000:3000 grafana/grafana

tput setaf 7; echo "-------------------------------------------------"
tput bold; tput setaf 7; echo "      => INSTALLATION TERMINEE <="
tput setaf 7; echo ""
tput bold; tput setaf 6; echo "                By PAPAMICA"
tput setaf 7; echo "-------------------------------------------------"
echo ""
docker container ls
