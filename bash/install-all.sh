#!/bin/bash

# Script d'installation de mes scripts getip et sping avec alias.
# Par Mickael Asseline (PAPAMICA)
# Compatibles avec toutes les distributions
# Compatible avec Bash et Zsh

echo ""
echo "Installation of dependencies"

packagesNeeded='speedtest-cli'
if [ -x "$(command -v apk)" ]; then 
        sudo apk add -y --no-cache $packagesNeeded
        echo "$packagesNeeded installed."
    elif [ -x "$(command -v apt-get)" ]; then 
        sudo apt-get install -y $packagesNeeded
        echo "$packagesNeeded installed."
    elif [ -x "$(command -v dnf)" ];     then 
        sudo dnf install -y $packagesNeeded
        echo "$packagesNeeded installed."
    elif [ -x "$(command -v zypper)" ];  then 
        sudo zypper install -y $packagesNeeded
        echo "$packagesNeeded installed."
    elif [ -x "$(command -v pacman)" ];  then 
        sudo pacman -S --noconfirm $packagesNeeded
        echo "$packagesNeeded installed."
    else 
        echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: $packagesNeeded">&2; 
fi

# Copie des scripts dans le dossier utilisateur
cp getip.sh ~/.getip.sh
cp sping.sh ~/.sping.sh

echo ""
echo "Current User : $USER"
echo "Current Shell : $SHELL"

if [[ $SHELL =~ "zsh"]]; then
    echo "alias getip=\"~/.getip.sh\"" >> ~/.zshrc
    echo "alias getip=\"~/.sping.sh\"" >> ~/.zshrc
    else
    echo "alias getip=\"~/.getip.sh\"" >> ~/.bashrc
    echo "alias getip=\"~/.sping.sh\"" >> ~/.bashrc
fi

echo ""
echo "Installation complete"
echo "You can use this commands : "
echo "     - getip"
echo "     - sping"