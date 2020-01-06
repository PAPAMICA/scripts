#!/bin/sh
####################################################
#                                                  #
# Configuration automatique de Debian par PAPAMICA #
#                                                  #
####################################################

# Changement des sources APT
echo "deb http://debian.mirrors.ovh.net/debian/ stretch main contrib non-free
deb-src http://debian.mirrors.ovh.net/debian/ stretch main contrib non-free

deb http://security.debian.org/ stretch/updates main contrib non-free
deb-src http://security.debian.org/ stretch/updates main contrib non-free

# stretch-updates, previously known as 'volatile'
deb http://debian.mirrors.ovh.net/debian/ stretch-updates main contrib non-free
deb-src http://debian.mirrors.ovh.net/debian/ stretch-updates main contrib non-free" > /etc/apt/sources.list
echo 'deb http://deb.debian.org/debian stretch-backports main' > \
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

chsh -s $(which zsh)

sh -c "$(curl -fsSL https://raw.githubusercontent.com/loket/oh-my-zsh/feature/batch-mode/tools/install.sh)" -s --batch || {
  echo "Could not install Oh My Zsh" >/dev/stderr
  exit 1
}

locale-gen --purge fr_FR.UTF-8
echo -e 'LANG="fr_FR.UTF-8"\nLANGUAGE="fr_FR:fr"\n' > /etc/default/locale


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

echo ""
echo ""
tput setaf 7; echo "-------------------------------------------------"
tput bold; tput setaf 7; echo "         => PREPARATION TERMINEE <="
tput setaf 7; echo ""
tput bold; tput setaf 7; echo "          Veuillez vous reconnecter"
tput bold; tput setaf 6; echo "                By PAPAMICA"
tput bold; tput setaf 6; echo "                Labo-Tech.fr"
tput setaf 7; echo "-------------------------------------------------"
tput setaf 2; echo ""
