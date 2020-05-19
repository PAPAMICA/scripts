#!/bin/bash
ip=8.8.8.8
temps=1

if [ "$1" != "" ]; then
    ip=$1
fi

if [ "$2" != "" ]; then
    temps=$2
fi


while sleep $temps; do
  t="0"  
  t="$(ping -c 1 $ip | tail -1| awk -F '/' '{print $5}')"
  if [ -z "$t" ]; then
    tput setaf 1; echo "ERROR"
  fi

  if [ -n "$t" ]; then
  t=${t%.*}
  ((t++))
    if [ "$t" -eq 1 ]; then
      tput setaf 2; echo "OK => <$t ms"
    elif [ "$t" -gt 1 ] && [ "$t" -le 100 ]; then
      tput setaf 2; echo "OK => $t ms"
    else
      tput setaf 3; echo "BAD => $t ms"
    fi
  fi
done