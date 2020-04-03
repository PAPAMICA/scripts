#!/bin/sh
####################################################
#                                                  #
# Configuration automatique de Debian par PAPAMICA #
#                                                  #
####################################################

# Changement des sources APT
echo "deb http://debian.mirrors.ovh.net/debian/ buster main contrib non-free
deb-src http://debian.mirrors.ovh.net/debian/ buster main contrib non-free

deb http://security.debian.org/ buster/updates main contrib non-free
deb-src http://security.debian.org/ buster/updates main contrib non-free

# buster-updates, previously known as 'volatile'
deb http://debian.mirrors.ovh.net/debian/ buster-updates main contrib non-free
deb-src http://debian.mirrors.ovh.net/debian/ buster-updates main contrib non-free" > /etc/apt/sources.list
echo 'deb http://deb.debian.org/debian buster-backports main' > \
 /etc/apt/sources.list.d/backports.list


# Mise à jours des paquets
apt update && apt upgrade -y
apt install -y sudo 
apt install -y chpasswd
apt install -y openssh-server
apt install -y cockpit
apt install -y locate
apt install -y zsh
apt install -y curl
apt install -y fonts-powerline

# Installation des dépendances et de docker
apt-get install -y apt-transport-https ca-certificates gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce docker-compose
systemctl enable docker
systemctl start docker

chsh -s $(which zsh)

sh -c "$(curl -fsSL https://raw.githubusercontent.com/loket/oh-my-zsh/feature/batch-mode/tools/install.sh)" -s --batch || {
  echo "Could not install Oh My Zsh" >/dev/stderr
  exit 1
}

locale-gen --purge fr_FR.UTF-8
echo -e 'LANG="fr_FR.UTF-8"\nLANGUAGE="fr_FR.UTF-8"\n' > /etc/default/locale


# Modification de zsh
for file in ~/.zshrc
do
  echo "Traitement de $file ..."
  sed -i -e "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=agnoster/g" "$file"
done

clear
tput setaf 7; echo "-------------------------------------------------"
tput bold; tput setaf 7; echo "    => Mise à jours des paquets effectué."
tput setaf 7; echo "-------------------------------------------------"
# Gestion des utilisateurs

tput setaf 2; read -p "Entrez le mot de passe pour Root : " password_root
tput setaf 2; echo "root:$password_root" | chpasswd
tput setaf 7; echo "-------------------------------------------------"
tput setaf 7; echo "    => Mot de passe de Root a été changé."
tput setaf 7; echo "-------------------------------------------------"
tput setaf 2; read -p "Entrez un nom d'utilisateur : " name_user
tput setaf 2; read -p "Entrez le mot de passe pour l'utilisateur $name_user : " password_user
tput setaf 2; adduser --quiet --disabled-password --shell /bin/bash --home /home/$name_user --gecos "User" $name_user
tput setaf 2; echo "$name_user:$password_user" | chpasswd
tput setaf 2; adduser $name_user sudo
tput setaf 7; echo "-------------------------------------------------"
tput bold; tput setaf 7; echo "    => L'utilisateur $name_user a été créé."
tput bold; tput setaf 7; echo "    => $name_user fait parti du groupe sudo."
tput setaf 7; echo "-------------------------------------------------"

# Changement du motd
ip_du_serveur=$(hostname -i)
tput setaf 7; echo "-------------------------------------------------"
tput bold; tput setaf 7; echo " => L'adresse IP du serveur est $ip_du_serveur."
tput setaf 7; echo "-------------------------------------------------"

tput setaf 2; read -p "Entrez le nom du serveur : " name_server
tput setaf 2; read -p "Entrez le nom de l'hébergeur : " name_provider

echo "
██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗
██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝
██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗
██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝
╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗
 ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝

             Server   : $name_server

             IP       : $ip_du_serveur

             Provider : $name_provider

" > /etc/motd
tput setaf 7; echo "-------------------------------------------------"
tput setaf 7; echo "          => Le MOTD a été changé."
tput setaf 7; echo "-------------------------------------------------"

updatedb

#Configuration et installation de Traefik et de Portainer
read -p "Entrez votre nom de domaine (ex : papamica.fr) : " ndd
read -p "Entrez votre adresse mail pour Let's Encrypt : " email

mkdir -p /apps/traefik
mkdir -p /apps/portainer

touch /apps/traefik/traefik.yml
echo "api:
  dashboard: true

entryPoints:
  http:
    address: \":80\"
  https:
    address: \":443\"

providers:
  docker:
    endpoint: \"unix:///var/run/docker.sock\"
    exposedByDefault: false

certificatesResolvers:
  http:
    acme:
      email: $email
      storage: acme.json
      httpChallenge:
        entryPoint: http

providers.file:
    filename: \"/etc/traefik/dynamic_conf.toml\"
    watch: true
" > /apps/traefik/traefik.yml

touch /apps/traefik/config.yml
echo "http:
  middlewares:
    https-redirect:
      redirectScheme:
        scheme: https

    default-headers:
      headers:
        frameDeny: true
        sslRedirect: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true

    secured:
      chain:
        middlewares:
        - default-headers
" > /apps/traefik/config.yml

touch acme.json

docker-compose up -d

clear
tput bold; tput setaf 7; echo "LISTES DES CONTAINERS EN COURS : "
tput setaf 3; echo ""
docker container ls

echo ""
echo ""
tput setaf 7; echo "-------------------------------------------------------"
tput bold; tput setaf 7; echo "              => PREPARATION TERMINEE <=               "
tput setaf 7; echo ""
tput bold; tput setaf 7; echo "Pensez à faire les redictions pour traefik et portainer"
tput bold; tput setaf 7; echo "          Identifiant Traefik : admin / admin          "
tput setaf 7; echo ""
tput bold; tput setaf 7; echo "               Veuillez vous reconnecter               "
tput bold; tput setaf 6; echo "                      By PAPAMICA                      "
tput bold; tput setaf 6; echo "                      Labo-Tech.fr                     "
tput setaf 7; echo "-------------------------------------------------------"
tput setaf 2; echo ""
