#!/bin/bash
clear
SERVER_IP=$(hostname -i)
# Installation des dépendances et de docker
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce docker-compose
systemctl enable docker
systemctl start docker

#Lancement du docker-compose.yml
docker-compose up -d

clear
tput bold; tput setaf 7; echo "LISTES DES CONTAINERS EN COURS : "
tput setaf 3; echo ""
docker container ls
echo ""
tput setaf 7; echo "--------------------------------------------------"
tput bold; tput setaf 7; echo "           => INSTALLATION TERMINEE <=           "
tput setaf 7; echo ""
tput setaf 7; echo "               Lien : $SERVER_IP:80               "
tput setaf 7; echo ""
tput bold; tput setaf 6; echo "                   By PAPAMICA                   "
tput bold; tput setaf 6; echo "                   wiki-tech.io                   "
tput setaf 7; echo "--------------------------------------------------"
tput setaf 2; echo ""

