#!/bin/zsh

# Getip by PAPAMICA
# Un simple script pour améliorer l'affichage de certaines informations essentielles.

# Utilisation : 
# Rendez executable le script avec "chmod +x getip.sh"
# Executez le avec "./getip.sh"

# Le paramètre "-s" permet de lancer un speedtest. (Nécessite speedtest-cli)

# Vous pouvez ajouter un alias pour le lancer avec une simple commande.


# Récuparation des informations 
ipadress=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
gateway=$(/sbin/ip route | awk '/default/ { print $3 }')
interface=$(ip route get 8.8.8.8 | awk -F"dev " 'NR==1{split($2,a," ");print a[1]}')
mask=$(ifconfig "$interface" | awk '/netmask/{ print $4;}')
dns=$(nmcli dev show | grep DNS | awk '{if(NR==1) print $2}')
dns2=$(nmcli dev show | grep DNS | awk '{if(NR==2) print $2}')
domain=$(nmcli dev show | grep DOMAIN | sed 's/\s\s*/\t/g' | cut -f 2)
mac=$(cat /sys/class/net/$interface/address)
ssid=$(iwgetid -r)
wan=$(curl -s http://whatismijnip.nl |cut -d " " -f 5) 
mtu=$(cat /sys/class/net/$interface/mtu)
rxerror=$(cat /sys/class/net/$interface/statistics/rx_errors)
txerror=$(cat /sys/class/net/$interface/statistics/tx_errors)
rxdropped=$(cat /sys/class/net/$interface/statistics/rx_dropped)
txdropped=$(cat /sys/class/net/$interface/statistics/tx_dropped)



# Affichage des informations
tput setaf 7; echo "________________________________________________"
echo ""
echo "Adresse IP LAN :       $ipadress"
echo "Passerelle :           $gateway"
echo "Masque :               $mask"
echo ""
echo "Serveur DNS :          $dns"
if [ -n $dns2 ]; then
echo "Serveur DNS 2 :        $dns2"
fi
echo "interface :            $interface"
echo "SSID :                 $ssid"
echo "Adresse MAC :          $mac"
echo "MTU :                  $mtu"
echo "Domaine :              $domain"
echo "Adresse IP WAN :       $wan"
tput setaf 7; echo "________________________________________________"
echo ""
echo "RX :                   $rxerror errors / $rxdropped dropped"
echo "TX :                   $txerror errors / $txdropped dropped"
echo ""

# Vérification de la connexion à Internet via IP
  t="0"  
  t="$(ping -c 1 8.8.8.8 | tail -1| awk -F '/' '{print $5}')"
  t=$(printf "%.0f" $t)
  if [ "$t" -eq 0 ]; then
    tput setaf 1; echo "INTERNET IP :          ERROR"
  elif [ "$t" -gt 0 ] && [ "$t" -le 100 ]; then
    tput setaf 2; echo "INTERNET IP :          OK => $t ms"
  else
    tput setaf 3; echo "INTERNET IP :          BAD => $t ms"
  fi

# Vérification de la connexion à Internet via DNS
  t="0"  
  t="$(ping -c 1 google.fr | tail -1| awk -F '/' '{print $5}')"
  t=$(printf "%.0f" $t)
  if [ "$t" -eq 0 ]; then
    tput setaf 1; echo "INTERNET DNS :         ERROR"
  elif [ "$t" -gt 0 ] && [ "$t" -le 100 ]; then
    tput setaf 2; echo "INTERNET DNS :         OK => $t ms"
  else
    tput setaf 3; echo "INTERNET DNS :         BAD => $t ms"
  fi

# Vérification de la connexion à la passerelle
  p="0"  
  p="$(ping -c 1 $gateway | tail -1| awk -F '/' '{print $5}')"
  p=$(printf "%.0f" $p)
  if [ "$t" -eq 0 ]; then
    tput setaf 1; echo "PASSERELLE :           ERROR"
  elif [ "$t" -gt 0 ] && [ "$p" -le 100 ]; then
    tput setaf 2; echo "PASSERELLE :           OK => $p ms"
  else
    tput setaf 3; echo "PASSERELLE :           BAD => $p ms"
  fi

# Vérification de la connexion au serveur DNS
  p="0"  
  p="$(ping -c 1 $dns | tail -1| awk -F '/' '{print $5}')"
  p=$(printf "%.0f" $p)
  if [ "$t" -eq 0 ]; then
    tput setaf 1; echo "SERVEUR DNS :          ERROR"
  elif [ "$t" -gt 0 ] && [ "$p" -le 100 ]; then
    tput setaf 2; echo "SERVEUR DNS :          OK => $p ms"
  else
    tput setaf 3; echo "SERVEUR DNS :          BAD => $p ms"
  fi
tput setaf 7; echo "________________________________________________"

# Si -s est présent, lancement du Speedtest
if [ -z $1 ]; then
    exit
fi

if [ $1 = "-s" ]; then
    echo ""
    speedtest > temp.txt
    declare -i upload=$(grep "Upload" "temp.txt" | awk '{print $2}')
    declare -i download=$(grep "Download" "temp.txt" | awk '{print $2}')
    fai=$(grep "Testing from" "temp.txt" | awk '{print $3}')
    rm temp.txt

    echo "FAI :                  $fai"
    if [ "$download" -eq 0 ];then
      tput setaf 1; echo "DOWNLOAD :             ERROR"
    elif [ "$download" -gt 0 ] && [ "$download" -le 2 ]; then 
      tput setaf 1; echo "DOWNLOAD :             BAD => $download Mbit/s"
    elif [ "$download" -gt 2 ] && [ "$download" -le 20 ]; then 
      tput setaf 3; echo "DOWNLOAD :             OK => $download Mbit/s"
    else
      tput setaf 2; echo "DOWNLOAD :             GOOD => $download Mbit/s"
    fi

    if [ "$upload" -eq 0 ];then
      tput setaf 1; echo "UPLOAD :               ERROR"
    elif [ "$upload" -gt 0 ] && [ "$upload" -le 2 ]; then 
      tput setaf 1; echo "UPLOAD :               BAD => $upload Mbit/s"
    elif [ "$upload" -gt 2 ] && [ "$upload" -le 20 ]; then 
      tput setaf 3; echo "UPLOAD :               OK => $upload Mbit/s"
    else
      tput setaf 2; echo "UPLOAD :               GOOD => $upload Mbit/s"
    fi
    tput setaf 7; echo "________________________________________________"
fi