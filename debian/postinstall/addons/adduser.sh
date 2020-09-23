#!/bin/bash

# Check if root
user=$(whoami)

if [ $(whoami) != "root" ]
  then
  tput setaf 5; echo "ERROR : Execute script with sudo or root user !"
  exit
fi

# Get new user informations
tput setaf 6; read -p "Please provide a name for a new user: " name
if [ "$name" == ""  ]; then
        tput setaf 5; echo "You did not entered a user name, so no user will be added after setup"
fi
tput setaf 6; read -p "Please provide a password for $name : " password
tput setaf 6; read -p "Add $name to sudo group ? (Y/n)" addsudo
if [ "$addsudo" == ""  ]; then
       addsudo=Y
fi

USER=$name
HOME=/home/$USER

# Add new user
echo "Add user $USER"
adduser $USER --disabled-login
echo "$USER:$password" | chpasswd
if [ "$addsudo" == "Y"  ]; then
       adduser $name_user sudo
fi

# Config new user
echo "generate .ssh dir in homedir for user $USER"
mkdir $HOME/.ssh
chmod 0700 $HOME/.ssh

echo "clone zsh git repo in $USER homedir"
git clone git://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
chmod 0755 $HOME/.oh-my-zsh

echo "setup default zsh settings"
cp $HOME/.oh-my-zsh/templates/zshrc.zsh-template $HOME/.zshrc
chmod 0755 $HOME/.zshrc

echo "set correct permissions"
chown -R $USER:$USER /home/$USER

echo "change shell for user $USER"
chsh --shell /bin/zsh $USER


echo ""
echo ""
tput setaf 7; echo "----------------------------------------------------------------------------------------------------"
tput bold; tput setaf 7; echo "                                       => USER $USER ADDED <=                                       "
tput setaf 7; echo ""
if [ "$addsudo" == "Y"  ]
  then
  tput bold; tput setaf 7; echo "                                      User added to sudo group                                      "
  tput setaf 7; echo ""
fi
tput bold; tput setaf 6; echo "                                            By PAPAMICA                                            "
tput bold; tput setaf 6; echo "                                    Labo-Tech.fr / Tech2Tech.fr                                    "
tput setaf 7; echo "----------------------------------------------------------------------------------------------------"
tput setaf 2; echo ""