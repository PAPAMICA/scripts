#!/bin/bash
clear
# Principaux paramètres
read -p "Entrez le mot de passe pour la base de données Zabbix : " ZABBIX_DB_USER_PASSWORD
#read -p "Entrez l'adresse ip du serveur : " SERVER_IP
SERVER_IP=$(hostname -i)

# Installation des dépendances et de docker
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce docker-compose
systemctl enable docker
systemctl start docker

# Récupération des images de Zabbix et de Grafana
docker pull zabbix/zabbix-server-pgsql:ubuntu-latest
docker pull grafana/grafana
docker pull postgres:latest

# Lancement du docker-compose.yml
cd zabbix
for file in zabbix/docker-compose.yml
do
  echo "Traitement de $file ..."
  sed -i -e "s/zabbix-bdd-password/$ZABBIX_DB_USER_PASSWORD/g" "$file"
  sed -i -e "s/ip-adress-zabbix/$SERVER_IP/g" "$file"
done
docker-compose up -d

clear

tput bold; tput setaf 7; echo "LISTES DES CONTAINERS EN COURS : "
docker container ls
tput setaf 7; echo "-------------------------------------------------"
tput bold; tput setaf 7; echo "      => INSTALLATION TERMINEE <="
tput setaf 7; echo ""
tput bold; tput setaf 6; echo "                By PAPAMICA"
tput setaf 7; echo "-------------------------------------------------"
echo ""

