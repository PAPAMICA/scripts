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


# Mise à jours des paquets
apt update && apt upgrade -y
apt install -y sudo
apt install -y chpasswd
apt install -y openssh-server
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

# Changement des couleurs
echo "export PS1=\"\[\e[32m\][\[\e[m\]\[\e[31m\]\u\[\e[m\]\[\e[33m\]@\[\e[m\]\[\e[32m\]\h\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[32m\]]\[\e[m\]\[\e[32;47m\]\\$\[\e[m\]\"" >> /root/.bashrc
echo "if [ \"$PS1\" ]; then

    normal=\"\[\e[0m\]\"
    Vert=\"\[\e[0;32m\]\"
    Rose=\"\[\e[0;35m\]\"
    Rouge=\"\[\e[0;31m\]\"
    #PS1='\u@\h:\w\$ '
    export PS1=\"$Vert\u$Rose@\h:\w$normal \"

    eval `dircolors -b`
    alias ls='ls --color=auto'
    alias ll='ls --color=auto -lh'
    alias dir='ls --color=auto --format=vertical'" >> /root/.bashrc
echo "include .bashrc if it exists if [ -f ~/.bashrc ]; then . ~/.bashrc fi" >> /root/.bash_profile

echo " export PS1=\"\[\e[32m\][\[\e[m\]\[\e[33m\]\u\[\e[m\]\[\e[33m\]@\[\e[m\]\[\e[32m\]\h\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[32m\]]\[\e[m\]\[\e[32;47m\]\\$\[\e[m\] \"" >> /home/$name_user/.bashrc
echo "if [ \"$PS1\" ]; then

    normal=\"\[\e[0m\]\"
    Vert=\"\[\e[0;32m\]\"
    Rose=\"\[\e[0;35m\]\"
    Rouge=\"\[\e[0;31m\]\"
    #PS1='\u@\h:\w\$ '
    export PS1=\"$Vert\u$Rose@\h:\w$normal \"

    eval `dircolors -b`
    alias ls='ls --color=auto'
    alias ll='ls --color=auto -lh'
    alias dir='ls --color=auto --format=vertical'" >> /home/$name_user/.bashrc
echo "include .bashrc if it exists if [ -f ~/.bashrc ]; then . ~/.bashrc fi" >> /home/$name_user/.bash_profile
tput setaf 7; echo "-------------------------------------------------"
tput bold; tput setaf 7; echo " => Le changement des couleurs est opérationnel."
tput setaf 7; echo "-------------------------------------------------"

echo ""
echo ""
tput setaf 7; echo "-------------------------------------------------"
tput bold; tput setaf 7; echo "         => PREPARATION TERMINEE <="
tput setaf 7; echo ""
tput bold; tput setaf 7; echo "          Veuillez vous reconnecter"
tput bold; tput setaf 6; echo "                By PAPAMICA"
tput setaf 7; echo "-------------------------------------------------"
