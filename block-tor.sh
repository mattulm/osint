#!/bin/bash
 
if [[ -z "$1" ]]; then
  echo Usage: $0 "<your host's ip>"
  exit 1
fi
 
hostip=$1
 
for i in $(wget https://check.torproject.org/cgi-bin/TorBulkExitList.py\?ip=$hostip -O- -q |\
    grep -E '^[[:digit:]]+(\.[[:digit:]]+){3}$'); do
  sudo iptables -A INPUT -s "$i" -j DROP
done