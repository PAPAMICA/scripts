#!/bin/zsh
if [ -z $1 ]; then
    1="8.8.8.8"
fi

if [ -z $2 ]; then
    2="1"
fi

while sleep $2; do
  t="0"  
  t="$(ping -c 1 $1 | tail -1| awk -F '/' '{print $5}')"
  t=$(printf "%.0f" $t)
  if [ "$t" -eq 0 ]; then
    tput setaf 1; echo "ERROR"
  elif [ "$t" -gt 0 ] && [ "$t" -le 100 ]; then
    tput setaf 2; echo "OK => $t ms"
  else
    tput setaf 3; echo "BAD => $t ms"
  fi
done