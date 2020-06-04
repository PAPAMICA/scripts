#!/bin/bash

# Script d'installation de mes scripts getip et sping avec alias.
# Par Mickael Asseline (PAPAMICA)
# Compatibles avec toutes les distributions
# Compatible avec Bash et Zsh

echo ""
tput setaf 2; echo "Installation of dependencies"
tput setaf 7; echo ""

packagesNeeded='speedtest-cli network-manager'
if [ -x "$(command -v apk)" ]; then 
        sudo apk add -y --no-cache $packagesNeeded
        tput setaf 2; echo "$packagesNeeded installed."
    elif [ -x "$(command -v apt-get)" ]; then 
        sudo apt-get install -y $packagesNeeded
        tput setaf 2; echo "$packagesNeeded installed."
    elif [ -x "$(command -v dnf)" ];     then 
        sudo dnf install -y $packagesNeeded
        tput setaf 2; echo "$packagesNeeded installed."
    elif [ -x "$(command -v zypper)" ];  then 
        sudo zypper install -y $packagesNeeded
        tput setaf 2; echo "$packagesNeeded installed."
    elif [ -x "$(command -v pacman)" ];  then 
        sudo pacman -S --noconfirm $packagesNeeded
        tput setaf 2; echo "$packagesNeeded installed."
    else 
        tput setaf 1; echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: $packagesNeeded">&2; 
fi
$DESKTOP_SESSION

tput setaf 7; echo ""
# Copie des scripts dans le dossier utilisateur
cp getip.sh ~/.getip.sh
chmod +x ~/.getip.sh

cp sping.sh ~/.sping.sh
chmod +x ~/.sping.sh


echo ""
tput setaf 2; echo "Current User : $USER"
tput setaf 2; echo "Current Shell : $SHELL"
tput setaf 2; echo "Current Desktop Session : $DESKTOP_SESSION"
tput setaf 7; echo ""
if [[ $SHELL =~ "zsh" ]]; then
    echo "alias getip=\"~/.getip.sh\"" >> ~/.zshrc
    echo "alias sping=\"~/.sping.sh\"" >> ~/.zshrc
    else
    echo "alias getip=\"~/.getip.sh\"" >> ~/.bashrc
    echo "alias sping=\"~/.sping.sh\"" >> ~/.bashrc
fi

tput setaf 2; echo ""
tput setaf 2; echo "Installation complete"
tput setaf 2; echo "Installation complete"
tput setaf 2; echo "After reconnect, you can use this commands : "
tput setaf 2; echo "     - getip"
tput setaf 2; echo "     - sping"