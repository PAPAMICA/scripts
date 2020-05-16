#!/bin/bash
clear
# Principaux paramètres
tput setaf 7; read -p "Entrez le mot de passe pour la base de données Zabbix : " ZABBIX_DB_USER_PASSWORD
read -p "Entrez l'adresse ip du serveur : " SERVER_IP
#SERVER_IP=$(hostname -i)
tput setaf 2; echo ""

# Installation des dépendances et de docker
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce docker-compose
apt-get install snmpd snmp
systemctl enable docker
systemctl enable snmpd
systemctl start docker
systemctl start snmpd

# Modification et lancement du docker-compose.yml
for file in ~/scripts/debian/zabbix-server/docker-compose.yml
do
  echo "Traitement de $file ..."
  sed -i -e "s/zabbix-bdd-password/$ZABBIX_DB_USER_PASSWORD/g" "$file"
done

docker-compose up -d

clear
tput bold; tput setaf 7; echo "LISTES DES CONTAINERS EN COURS : "
tput setaf 3; echo ""
docker container ls
echo ""
tput setaf 7; echo "-------------------------------------------------"
tput bold; tput setaf 7; echo "         => INSTALLATION TERMINEE <="
tput setaf 7; echo ""
tput setaf 7; echo "   IP du serveur Zabbix : $SERVER_IP:8090      "
tput setaf 7; echo "         ID : Admin / MDP : zabbix             "
tput setaf 7; echo ""
tput setaf 7; echo "   IP du serveur Grafana : $SERVER_IP:3000     "
tput setaf 7; echo "         ID : admin / MDP : admin              "
tput setaf 7; echo ""
tput bold; tput setaf 6; echo "                By PAPAMICA"
tput bold; tput setaf 6; echo "                Labo-Tech.fr"
tput setaf 7; echo "-------------------------------------------------"
tput setaf 2; echo ""

