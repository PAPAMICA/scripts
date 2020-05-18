#!/bin/bash

# Getip by PAPAMICA
# Un simple script pour améliorer l'affichage de certaines informations essentielles.

# Utilisation : 
# Rendez executable le script avec "chmod +x getip.sh"
# Executez le avec "./getip.sh"

# Le paramètre "-s" permet de lancer un speedtest. (Nécessite speedtest-cli)

# Vous pouvez ajouter un alias pour le lancer avec une simple commande.

interface=$(ip route get 8.8.8.8 | awk -F"dev " 'NR==1{split($2,a," ");print a[1]}')



if [[ $1 =~ "i" ]]; then
  int1=$(nmcli con show --active | awk '{if(NR==2) print $(NF-1)}')
  intname1=$(nmcli con show --active | awk '{if(NR==2) print $NF}')
  int2=$(nmcli con show --active | awk '{if(NR==3) print $(NF-1)}')
  intname2=$(nmcli con show --active | awk '{if(NR==3) print $NF}')
  int3=$(nmcli con show --active | awk '{if(NR==4) print $(NF-1)}')
  intname3=$(nmcli con show --active | awk '{if(NR==4) print $NF}')
  int4=$(nmcli con show --active | awk '{if(NR==5) print $(NF-1)}')
  intname4=$(nmcli con show --active | awk '{if(NR==5) print $NF}')
  int5=$(nmcli con show --active | awk '{if(NR==6) print $(NF-1)}')
  intname5=$(nmcli con show --active | awk '{if(NR==6) print $NF}')
  int6=$(nmcli con show --active | awk '{if(NR==7) print $(NF-1)}')
  intname6=$(nmcli con show --active | awk '{if(NR==7) print $NF}')
  int7=$(nmcli con show --active | awk '{if(NR==8) print $(NF-1)}')
  intname7=$(nmcli con show --active | awk '{if(NR==8) print $NF}')
  int8=$(nmcli con show --active | awk '{if(NR==9) print $(NF-1)}')
  intname8=$(nmcli con show --active | awk '{if(NR==9) print $NF}')
  int9=$(nmcli con show --active | awk '{if(NR==10) print $(NF-1)}')
  intname10=$(nmcli con show --active | awk '{if(NR==10) print $NF}')

  tput setaf 7; echo "________________________________________________"
  echo ""
  #echo "Liste des interfaces :"
  io=0
  if [ -n $int1 ]; then
    echo "     1 - $int1 ($intname1)"
    ((io++))  
  fi
  if [ "$int2" != "" ]; then
    echo "     2 - $int2 ($intname2)"
    ((io++))  
  fi
  if [ "$int3" != "" ]; then
    echo "     3 - $int3 ($intname3)"
    ((io++))
  fi
  if [ "$int4" != "" ]; then
    echo "     4 - $int4 ($intname4)"
    ((io++)) 
  fi
  if [ "$int5" != "" ]; then
    echo "     5 - $int5 ($intname5)"
    ((io++)) 
  fi
  if [ "$int6" != "" ]; then
    echo "     6 - $int6 ($intname6)"
    ((io++)) 
  fi
  if [ "$int7" != "" ]; then
    echo "     7 - $int7 ($intname7)"
    ((io++))
  fi
  if [ "$int8" != "" ]; then
    echo "     8 - $int8 ($intname8)"
    ((io++)) 
  fi
  if [ "$int9" != "" ]; then
    echo "     9 - $int9 ($intname9)"
    ((io++)) 
  fi
  echo ""
  read -p "Choisissez l'interface (1-$io) : " intchoix

  if [ "$intchoix" -lt 1 ] && [ "$intchoix" -gt $io ]; then
    echo "Merci de saisir un bon numero !"
    exit
  fi
  if [ "$intchoix" = 1 ]; then
    interface=$intname1
  fi
  if [ "$intchoix" = 2 ]; then
    interface=$intname2
  fi
  if [ "$intchoix" = 3 ]; then
    interface=$intname3
  fi
  if [ "$intchoix" = 4 ]; then
    interface=$intname4
  fi
  if [ "$intchoix" = 5 ]; then
    interface=$intname5
  fi
  if [ "$intchoix" = 6 ]; then
    interface=$intname6
  fi
  if [ "$intchoix" = 7 ]; then
    interface=$intname7
  fi
  if [ "$intchoix" = 8 ]; then
    interface=$intname8
  fi
  if [ "$intchoix" = 9 ]; then
    interface=$intname9
  fi
  
fi

if [[ $1 =~ "r" ]]; then
  gateway=$(nmcli dev show $interface |grep IP4.GATEWAY | awk '{print $2 }')
  echo ""
  tput setaf 3; echo "  Le changement de route par defaut nécessite les droits root."
  sudo route del default
  sudo route add default gw $gateway $interface
  tput setaf 2; echo "  Route par defaut modifiée pour passer par $interface"
fi



# Récuparation des informations 
ipadress=$(ifconfig "$interface" | awk '/inet /{ print $2;}')
gateway=$(nmcli dev show $interface |grep IP4.GATEWAY | awk '{print $2 }')
mask=$(ifconfig "$interface" | awk '/netmask/{ print $4;}')
dns=$(nmcli dev show $interface | grep DNS | awk '{if(NR==1) print $2}')
dns2=$(nmcli dev show $interface |grep DNS | awk '{if(NR==2) print $2}')
domain=$(nmcli dev show $interface | grep DOMAIN | sed 's/\s\s*/\t/g' | cut -f 2)
mac=$(cat /sys/class/net/$interface/address)
nom=$(nmcli dev show $interface |grep GENERAL.CONNECTION | awk '{print $2 " "  $3 " " $4 " " $5 " " $6}')
ping="$(ping -c 1 google.fr | tail -1| awk -F '/' '{print $5}')"
if [ "$t" != 0 ]; then
wan=$(curl -s ifconfig.io)
fi
mtu=$(cat /sys/class/net/$interface/mtu)
rxerror=$(cat /sys/class/net/$interface/statistics/rx_errors)
txerror=$(cat /sys/class/net/$interface/statistics/tx_errors)
rxdropped=$(cat /sys/class/net/$interface/statistics/rx_dropped)
txdropped=$(cat /sys/class/net/$interface/statistics/tx_dropped)




# Affichage des informations
tput setaf 7; echo "________________________________________________"
echo ""
echo "  Adresse IP LAN :       $ipadress"
echo "  Passerelle :           $gateway"
echo "  Masque :               $mask"
echo ""
echo "  Serveur DNS :          $dns"
if [ -n $dns2 ]; then
echo "  Serveur DNS 2 :        $dns2"
fi
echo "  interface :            $interface"
echo "  Nom :                  $nom"
echo "  Adresse MAC :          $mac"
echo "  MTU :                  $mtu"
echo "  Domaine :              $domain"
echo "  Adresse IP WAN :       $wan"
tput setaf 7; echo "________________________________________________"
echo ""
echo "  RX :                   $rxerror errors / $rxdropped dropped"
echo "  TX :                   $txerror errors / $txdropped dropped"
echo ""

# Vérification de la connexion à Internet via IP
  t="0"  
  t="$(ping -c 1 8.8.8.8 | tail -1| awk -F '/' '{print $5}')"
  t=${t%.*}
  if [ "$t" -eq 0 ]; then
    tput setaf 1; echo "  INTERNET IP :          ERROR"
  elif [ $t -gt 0 ] && [ $t -le 100 ]; then
    tput setaf 2; echo "  INTERNET IP :          OK => $t ms"
  else
    tput setaf 3; echo "  INTERNET IP :          BAD => $t ms"
  fi

# Vérification de la connexion à Internet via DNS
  t="0"  
  t="$(ping -c 1 google.fr | tail -1| awk -F '/' '{print $5}')"
  t=${t%.*}
  if [ "$t" -eq 0 ]; then
    tput setaf 1; echo "  INTERNET DNS :         ERROR"
  elif [ "$t" -gt 0 ] && [ "$t" -le 100 ]; then
    tput setaf 2; echo "  INTERNET DNS :         OK => $t ms"
  else
    tput setaf 3; echo "  INTERNET DNS :         BAD => $t ms"
  fi

# Vérification de la connexion à la passerelle
  p="0"  
  p="$(ping -c 1 $gateway | tail -1| awk -F '/' '{print $5}')"
  p=${p%.*}
  if [ "$p" -eq 0 ]; then
    tput setaf 1; echo "  PASSERELLE :           ERROR"
  elif [ "$p" -gt 0 ] && [ "$p" -le 100 ]; then
    tput setaf 2; echo "  PASSERELLE :           OK => $p ms"
  else
    tput setaf 3; echo "  PASSERELLE :           BAD => $p ms"
  fi

# Vérification de la connexion au serveur DNS
  p="0"  
  p="$(ping -c 1 $dns | tail -1| awk -F '/' '{print $5}')"
  p=${p%.*}
  if [ "$t" -eq 0 ]; then
    tput setaf 1; echo "  SERVEUR DNS :          ERROR"
  elif [ "$t" -gt 0 ] && [ "$p" -le 100 ]; then
    tput setaf 2; echo "  SERVEUR DNS :          OK => $p ms"
  else
    tput setaf 3; echo "  SERVEUR DNS :          BAD => $p ms"
  fi
tput setaf 7; echo "________________________________________________"

# Si -s est présent, lancement du Speedtest
if [ -z $1 ]; then
    exit
fi

if [[ $1 =~ "s" ]]; then
    echo ""
    speedtest > temp.txt
    ping=$(grep "Hosted" "temp.txt" | awk '{print $(NF-1)}')
    upload=$(grep "Upload" "temp.txt" | awk '{print $2}')
    download=$(grep "Download" "temp.txt" | awk '{print $2}')
    fai=$(grep "Testing from" "temp.txt" | awk '{print $3}')
    rm temp.txt

    echo "  FAI :                  $fai"

    ping=${ping%.*}
    if [ "$t" -eq 0 ]; then
      tput setaf 1; echo "  PING MOYEN :           ERROR"
    elif [ "$t" -gt 0 ] && [ "$p" -le 100 ]; then
      tput setaf 2; echo "  PING MOYEN :           OK => $ping ms"
    else
      tput setaf 3; echo "  PING MOYEN :           BAD => $ping ms"
    fi

    download=${download%.*}
    if [ "$download" -eq 0 ];then
      tput setaf 1; echo "  DOWNLOAD :             ERROR"
    elif [ "$download" -gt 0 ] && [ "$download" -le 2 ]; then 
      tput setaf 1; echo "  DOWNLOAD :             BAD => $download Mbit/s"
    elif [ "$download" -gt 2 ] && [ "$download" -le 20 ]; then 
      tput setaf 3; echo "  DOWNLOAD :             OK => $download Mbit/s"
    else
      tput setaf 2; echo "  DOWNLOAD :             GOOD => $download Mbit/s"
    fi

    upload=${upload%.*}
    if [ "$upload" -eq 0 ];then
      tput setaf 1; echo "  UPLOAD :               ERROR"
    elif [ "$upload" -gt 0 ] && [ "$upload" -le 2 ]; then 
      tput setaf 1; echo "  UPLOAD :               BAD => $upload Mbit/s"
    elif [ "$upload" -gt 2 ] && [ "$upload" -le 20 ]; then 
      tput setaf 3; echo "  UPLOAD :               OK => $upload Mbit/s"
    else
      tput setaf 2; echo "  UPLOAD :               GOOD => $upload Mbit/s"
    fi
    tput setaf 7; echo "________________________________________________"
fi
