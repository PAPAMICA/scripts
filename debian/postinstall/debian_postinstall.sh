#!/bin/bash
####################################################
#                                                  #
# Configuration automatique de Debian par PAPAMICA #
#                                                  #
####################################################


function Verif-System {
  user=$(whoami)

  if [ $(whoami) != "root" ]
    then
    tput setaf 5; echo "ERREUR : Veuillez exécuter le script en tant que Root !"
    exit
  fi

  if [[ $(arch) != *"64" ]]
    then
    tput setaf 5; echo "ERREUR : Veuillez installer une version x64 !"
    exit
  fi
  
}

# Changement des sources APT
version=$(grep "VERSION=" /etc/os-release |awk -F= {' print $2'}|sed s/\"//g |sed s/[0-9]//g | sed s/\)$//g |sed s/\(//g)
function Change-Source {
  echo "deb http://debian.mirrors.ovh.net/debian/ $version main contrib non-free
  deb-src http://debian.mirrors.ovh.net/debian/ $version main contrib non-free
  
  deb http://security.debian.org/ $version/updates main contrib non-free
  deb-src http://security.debian.org/ $version/updates main contrib non-free
  
  # $version-updates, previously known as 'volatile'
  deb http://debian.mirrors.ovh.net/debian/ $version-updates main contrib non-free
  deb-src http://debian.mirrors.ovh.net/debian/ $version-updates main contrib non-free" > /etc/apt/sources.list
  echo 'deb http://deb.debian.org/debian $version-backports main' > \
   /etc/apt/sources.list.d/backports.list
}


# Mise à jours des paquets
function Install-PaquetsEssentiels {
  apt update && apt upgrade -y
  apt install -y sudo 
  apt install -y chpasswd
  apt install -y openssh-server
  apt install -y cockpit
  apt install -y locate
  apt install -y zsh
  apt install -y curl
  apt install -y fonts-powerline
  apt install -y fail2ban
}

# Installation des dépendances et de docker
function Install-Docker {
  tput setaf 2; apt-get install -y apt-transport-https ca-certificates gnupg2 software-properties-common
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
  apt-get update
  apt-get -y install docker-ce docker-compose
  systemctl enable docker
  systemctl start docker
}

function Install-Zsh {
  tput setaf 2; chsh -s $(which zsh)

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
}

function Update-db {
  updatedb
}
#Configuration et installation de Traefik et de Portainer
function Install-TraefikPortainer {

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
  
  touch /apps/traefik/acme.json
  chmod 600 /apps/traefik/acme.json
  
  touch docker-compose.yml
  echo "version: '2'
  
services:
  traefik:
    image: traefik:latest
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
      - proxy
    ports:
      - 80:80
      - 443:443
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /apps/traefik/traefik.yml:/traefik.yml:ro
      - /apps/traefik/acme.json:/acme.json
      - /apps/traefik/config.yml:/config.yml:ro
    labels:
      - traefik.enable=true
      - traefik.http.routers.traefik.entrypoints=http
      - traefik.http.routers.traefik.rule=Host(\"traefik.$ndd\")
      - traefik.http.middlewares.traefik-auth.basicauth.users=admin:{SHA}0DPiKuNIrrVmD8IUCuw1hQxNqZc=
      - traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https
      - traefik.http.routers.traefik.middlewares=traefik-https-redirect
      - traefik.http.routers.traefik-secure.entrypoints=https
      - traefik.http.routers.traefik-secure.rule=Host(\"traefik.$ndd\")
      - traefik.http.routers.traefik-secure.middlewares=traefik-auth
      - traefik.http.routers.traefik-secure.tls=true
      - traefik.http.routers.traefik-secure.tls.certresolver=http
      - traefik.http.routers.traefik-secure.service=api@internal


  portainer:
    image: portainer/portainer:latest
    container_name: portainer
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
      - proxy
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /apps/portainer/data:/data
    labels:
      - traefik.enable=true
      - traefik.http.routers.portainer.entrypoints=http
      - traefik.http.routers.portainer.rule=Host(\"portainer.$ndd\")
      - traefik.http.middlewares.portainer-https-redirect.redirectscheme.scheme=https
      - traefik.http.routers.portainer.middlewares=portainer-https-redirect
      - traefik.http.routers.portainer-secure.entrypoints=https
      - traefik.http.routers.portainer-secure.rule=Host(\"portainer.$ndd\")
      - traefik.http.routers.portainer-secure.tls=true
      - traefik.http.routers.portainer-secure.tls.certresolver=http
      - traefik.http.routers.portainer-secure.service=portainer
      - traefik.http.services.portainer.loadbalancer.server.port=9000
      - traefik.docker.network=proxy
    

networks:
  proxy:
    external: true
  " > docker-compose.yml

  tput setaf 2; docker network create proxy
  docker-compose up -d
}

function Change-Password {
  tput setaf 6; echo "root:$password_root" | chpasswd
  tput setaf 7; echo "----------------------------------------------------------------------------------------------------"
  tput setaf 7; echo "                                => Mot de passe de Root a été changé.                               "
  tput setaf 7; echo "----------------------------------------------------------------------------------------------------"
  tput setaf 2; adduser --quiet --disabled-password --shell /bin/bash --home /home/$name_user --gecos "User" $name_user
  tput setaf 2; echo "$name_user:$password_user" | chpasswd
  tput setaf 2; adduser $name_user sudo
  tput setaf 7; echo "----------------------------------------------------------------------------------------------------"
  tput bold; tput setaf 7; echo "                         => L'utilisateur $name_user a été créé.                         "
  tput bold; tput setaf 7; echo "                         => $name_user fait parti du groupe sudo.                        "
  tput setaf 7; echo "----------------------------------------------------------------------------------------------------"
}

# Changement du port SSH
function Change-SSHPort {
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config_backup

  for file in /etc/ssh/sshd_config
  do
    echo "Traitement de $file ..."
    sed -i -e "s/#Port 22/Port $ssh_port/" "$file"
  done  
  tput setaf 7; echo "----------------------------------------------------------------------------------------------------"
  tput setaf 7; echo "                                 => Port SSH remplacé par $ssh_port.                                "
  tput setaf 7; echo "----------------------------------------------------------------------------------------------------"

}

# Changement du motd
function Change-MOTD {
  ip_du_serveur=$(hostname -i)
  tput setaf 7; echo "----------------------------------------------------------------------------------------------------"
  tput bold; tput setaf 7; echo "                      => L'adresse IP du serveur est $ip_du_serveur.                     "
  tput setaf 7; echo "----------------------------------------------------------------------------------------------------"


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
  
}
#-----------------------------------------------------------------------------------------------------------------------------------
clear
tput setaf 7; echo "----------------------------------------------------------------------------------------------------"
tput setaf 7; echo "                                   Script d'installation de Debian                                  "
tput setaf 7; echo "----------------------------------------------------------------------------------------------------"

tput setaf 6; read -p "Souhaitez vous créer les utilisateurs ? (y/n)  " create_user
if [ $create_user = "y" ]
  then
    tput setaf 6; read -p "===>     Entrez le mot de passe pour Root : " password_root
    tput setaf 6; read -p "===>     Entrez un nom d'utilisateur : " name_user
    tput setaf 6; read -p "===>     Entrez le mot de passe pour l'utilisateur $name_user : " password_user
fi
echo ""

tput setaf 6; read -p "Souhaitez vous changer le port SSH ? (recommandé) (y/n)  " change_sshport
if [ $change_sshport = "y" ]
  then
    tput setaf 6; read -p "===>     Entrez port que vous souhaitez (ex : 2020) : " ssh_port
fi
echo ""

tput setaf 6; read -p "Souhaitez vous changer le MOTD ? (y/n)  " change_motd
if [ $change_motd = "y" ]
  then
  tput setaf 6; read -p "===>     Entrez le nom du serveur : " name_server
  tput setaf 6; read -p "===>     Entrez le nom de l'hébergeur : " name_provider
fi
echo ""

tput setaf 6; read -p "Souhaitez vous installer Docker ? (y/n)  " install_docker
if [ $install_docker = "y" ]
  then
  echo ""
  tput setaf 6; read -p "Souhaitez vous installer Traefik et Portainer ? (y/n)  " install_traefik
  if [ $install_traefik = "y" ]
    then
    tput setaf 6; read -p "===>     Entrez votre nom de domaine (ex : papamica.fr) : " ndd
    tput setaf 6; read -p "===>     Entrez votre adresse mail pour Let's Encrypt : " email
  fi
fi
echo ""
tput setaf 7; echo "----------------------------------------------------------------------------------------------------"
tput setaf 7; echo "                                           Début du script                                          "
tput setaf 7; echo "----------------------------------------------------------------------------------------------------"
echo ""
echo ""


tput setaf 6; echo "Vérification du système ................................................................... En cours"
Verif-System
tput setaf 7; echo "Vérification du système ................................................................... OK"
echo ""


tput setaf 6; echo "Configuration des sources ................................................................. En cours"
Change-Source
tput setaf 7; echo "Configuration des sources ................................................................. OK"
echo ""

tput setaf 6; echo "Installation des paquets essentiels........................................................ En cours"
Install-PaquetsEssentiels
tput setaf 7; echo "Installation des paquets essentiels........................................................ OK"
echo ""

tput setaf 6; echo "Installation de ZSH........................................................................ En cours"
Install-Zsh
tput setaf 7; echo "Installation de ZSH........................................................................ OK"
echo ""

tput setaf 6; echo "Mise à jour de la base de données.......................................................... En cours"
Update-db
tput setaf 7; echo "Mise à jour de la base de données.......................................................... OK"

echo ""
echo ""
if [ $install_docker = "y" ]
  then
  tput setaf 6; echo "Installation de Docker..................................................................... En cours"
  Install-Docker
  tput setaf 7; echo "Installation de Docker..................................................................... OK"
fi

echo ""
echo ""
if [ $install_traefik = "y" ]
  then
  tput setaf 6; echo "Installation de Traefik et de Portainer.................................................... En cours"
  Install-TraefikPortainer
  tput setaf 7; echo "Installation de Traefik et de Portainer.................................................... OK"
fi

echo ""
echo ""
if [ $create_user = "y" ]
  then
  tput setaf 6; echo "Création des utilisateurs et changement des mots de passe.................................. En cours"
  Change-Password
  tput setaf 6; echo "Création des utilisateurs et changement des mots de passe.................................. OK"
fi

echo ""
echo ""
if [ $change_sshport = "y" ]
  then
  tput setaf 6; echo "Changement du port SSH.................................................................... En cours"
  Change-SSHPort
  tput setaf 6; echo "Changement du port SSH.................................................................... OK"
fi

echo ""
echo ""
if [ $change_motd = "y" ] 
  then
  tput setaf 6; echo "Changement du MOTD....................................................................... En cours"
  Change-MOTD
  tput setaf 6; echo "Changement du MOTD....................................................................... OK"
fi

echo ""
echo ""
if [ $install_traefik = "y" ]
  then
  echo ""
  echo ""
  tput bold; tput setaf 7; echo "LISTES DES CONTAINERS EN COURS : "
  tput setaf 3; echo ""
  docker container ls
fi

echo ""
echo ""
tput setaf 7; echo "----------------------------------------------------------------------------------------------------"
tput bold; tput setaf 7; echo "                               => PREPARATION TERMINEE <=                                "
tput setaf 7; echo ""
if [ $install_traefik = "y" ]
  then
  tput bold; tput setaf 7; echo "                Pensez à faire les redictions pour traefik et portainer                "
  tput bold; tput setaf 7; echo "                          Identifiant Traefik : admin / admin                          "
  tput setaf 7; echo ""
fi
tput bold; tput setaf 7; echo "                                Veuillez vous reconnecter                                "
if [ $change_sshport = "y"]
  then
  tput bold; tput setaf 7; echo "                             Votre nouveau port SSH : $ssh_port                        "
fi
tput setaf 7; echo ""
tput bold; tput setaf 6; echo "                                       By PAPAMICA                                       "
tput bold; tput setaf 6; echo "                               Labo-Tech.fr / Tech2Tech.fr                               "
tput setaf 7; echo "----------------------------------------------------------------------------------------------------"
tput setaf 2; echo ""

sleep 5
# Redémarrage du service sshd
/etc/init.d/sshd restart

