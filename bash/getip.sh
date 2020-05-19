#!/bin/bash

# Getip by Mickael Asseline (PAPAMICA)

# A simple script to improve the display of certain essential information.

# Use : 
# Make the script executable with "chmod +x getip.sh"
# Execute it with "./getip.sh"

# The "-s" parameter is used to launch a speedtest. (Require speedtest-cli)

# You can add an alias to launch it with a simple command.

if [[ $1 =~ "h" ]]; then
  echo ""
  tput setaf 7; echo "________________________________________________________________________________"
  echo ""
  echo "             Bash script to improve the reading of network informations         "
  echo "                      created by Mickael Asseline (PAPAMICA)                    "
  echo ""
  echo "  Options availables :"
  echo "     -s      Launch a speedtest (require speedtest-cli)"
  echo "     -i      Allows the choice of the interface to display"
  echo "     -r      Change the default route by the chosen interface"
  echo "              (For speedtest and pings tests)"
  echo "     -h      Diplay this help"
  echo ""
  echo "  Use :"
  echo "     getip       IP informations"
  echo "     getip -s    IP informations + Speedtest"
  echo "     getip -i    IP informations + Choice interface"
  echo "     getip -ir   IP informations + Choice interface + Change route"
  echo "     getip -sir  IP informations + Choice interface + Change route + Speedtest"
  echo 
  exit
fi


network=$(nmcli con show --active)
if [ "$network" = "" ]; then
  tput setaf 1; echo "Pas d'interfaces actives !"
  exit
fi

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
  read -p "  Choice interface (1-$io) : " intchoix

  if [ "$intchoix" -lt 1 ] && [ "$intchoix" -gt $io ]; then
    echo "  Error : choice interface !"
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
  tput setaf 3; echo "  Requires root rights."
  sudo route del default
  sudo route add default gw $gateway $interface
  tput setaf 2; echo "  The default route has been changed to pass to $interface"
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
mtu=$(cat /sys/class/net/$interface/mtu)
rxerror=$(cat /sys/class/net/$interface/statistics/rx_errors)
txerror=$(cat /sys/class/net/$interface/statistics/tx_errors)
rxdropped=$(cat /sys/class/net/$interface/statistics/rx_dropped)
txdropped=$(cat /sys/class/net/$interface/statistics/tx_dropped)




# Affichage des informations
tput setaf 7; echo "________________________________________________"
echo ""
echo "  LAN IP Address :       $ipadress"
echo "  Gateway :              $gateway"
echo "  Mask :                 $mask"
echo ""
echo "  DNS Server :           $dns"
if [ -n $dns2 ]; then
echo "  DNS Server 2 :         $dns2"
fi
echo "  Interface :            $interface"
echo "  Name :                 $nom"
echo "  MAC Address :          $mac"
echo "  MTU :                  $mtu"
echo "  Domain :               $domain"

ping="$(ping -c 1 google.fr | tail -1| awk -F '/' '{print $5}')"
if [ "$ping" != 0 ]; then
wan=$(curl -s ifconfig.io)
fi

echo "  WAN IP Address :       $wan"
tput setaf 7; echo "________________________________________________"
echo ""
echo "  RX :                   $rxerror errors / $rxdropped dropped"
echo "  TX :                   $txerror errors / $txdropped dropped"
echo ""

# Vérification de la connexion à Internet via IP
  t="0"  
  t="$(ping -c 1 8.8.8.8 | tail -1| awk -F '/' '{print $5}')"
  if [ -z "$t" ]; then
    tput setaf 1; echo "  INTERNET IP :          ERROR"
  fi

  if [ -n "$t" ]; then
  t=${t%.*}
  ((t++))
    if [ "$t" -eq 1 ]; then
    tput setaf 2; echo "  INTERNET IP :          OK => <$t ms"
    elif [ "$t" -gt 1 ] && [ "$t" -le 100 ]; then
    tput setaf 2; echo "  INTERNET IP :          OK => $t ms"
    else
    tput setaf 3; echo "  INTERNET IP :          BAD => $t ms"
    fi
  fi


# Vérification de la connexion à Internet via DNS
  t="0"  
  t="$(ping -c 1 google.fr | tail -1| awk -F '/' '{print $5}')"
  if [ -z "$t" ]; then
    tput setaf 1; echo "  INTERNET DNS :         ERROR"
  fi

  if [ -n "$t" ]; then
  t=${t%.*}
  ((t++))
    if [ "$t" -eq 1 ]; then
    tput setaf 2; echo "  INTERNET DNS :         OK => <$t ms"
    elif [ "$t" -gt 1 ] && [ "$t" -le 100 ]; then
    tput setaf 2; echo "  INTERNET DNS :         OK => $t ms"
    else
    tput setaf 3; echo "  INTERNET DNS :         BAD => $t ms"
    fi
  fi

# Vérification de la connexion à la passerelle
  t="0"  
  t="$(ping -c 1 $gateway | tail -1| awk -F '/' '{print $5}')"
  if [ -z "$t" ]; then
    tput setaf 1; echo "  GATEWAY :              ERROR"
  fi

  if [ -n "$t" ]; then
  t=${t%.*}
  ((t++))
    if [ "$t" -eq 1 ]; then
    tput setaf 2; echo "  GATEWAY :              OK => <$t ms"
    elif [ "$t" -gt 1 ] && [ "$t" -le 100 ]; then
    tput setaf 2; echo "  GATEWAY :              OK => $t ms"
    else
    tput setaf 3; echo "  GATEWAY :              BAD => $t ms"
    fi
  fi

# Vérification de la connexion au serveur DNS
  t="0"  
  t="$(ping -c 1 $dns | tail -1| awk -F '/' '{print $5}')"
  if [ -z "$t" ]; then
    tput setaf 1; echo "  DNS SERVER :           ERROR"
  fi

  if [ -n "$t" ]; then
  t=${t%.*}
  ((t++))
    if [ "$t" -eq 1 ]; then
    tput setaf 2; echo "  DNS SERVER :           OK => <$t ms"
    elif [ "$t" -gt 1 ] && [ "$t" -le 100 ]; then
    tput setaf 2; echo "  DNS SERVER :           OK => $t ms"
    else
    tput setaf 3; echo "  DNS SERVER :           BAD => $t ms"
    fi
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
    if [ "$ping" -eq 0 ]; then
      tput setaf 1; echo "  PING :                 ERROR"
    elif [ "$ping" -gt 0 ] && [ "$ping" -le 100 ]; then
      tput setaf 2; echo "  PING :                 OK => $ping ms"
    else
      tput setaf 3; echo "  PING :                 BAD => $ping ms"
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

if [[ $1 =~ "r" ]]; then
  echo ""
  tput setaf 3; read -p "  Reset the default route? (y/n) : " dellroute
  if [[ "$dellroute" = "y" ]]; then
    sudo route del default
    sudo systemctl restart NetworkManager
  fi
  tput setaf 2; echo "  Default route reset."
fi