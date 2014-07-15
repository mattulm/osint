#!/bin/bash
#####
# Description: Some information about the source
#
# Name: Feodo Bot TRacker
# Host: Abuse.ch (The Swiss Security Blog.)
# Frequency: Daily
# Types: IPv4, domain, hashes
#####
# Some Variables
HOME="/tmp/osint"
SOURCES="/tmp/osint/sources"
HEADER="Accept: text/html"
UA21="Mozilla/5.0 Gecko/20100101 Firefox/21.0"
UA22="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13; ) Gecko/20101203"
TODAY=$(date +"%Y-%m-%d")
if [ ! -d "/tmp/ossint/sources/tornodes" ]; then
        mkdir -p /tmp/osint/sources/tornodes;
fi
datadirs=( ipv4 domains hashes rules )
for i in "${datadirs[@]}"; do
        if [ ! -d "$HOME/$i" ]; then
                mkdir -p $HOME/$i
        fi
done
#####################################
cd $SOURCES/tornodes
#
# Let's get all of the files we are going to work on first.
# we have to do different sets of tasks on each file, as they format things differently.
if [[ $(date +%u) -gt 6 ]] ; then
	wget --no-check-certificate  "https://www.dan.me.uk/torlist/" -O "ukdan.list"
fi
wget "http://torstatus.blutmagie.de/ip_list_all.php/Tor_ip_list_ALL.csv" -O "german.list"
wget --no-check-certificate "https://check.torproject.org/exit-addresses" -O "torsite.txt"
wget "http://en.wikipedia.org/wiki/Category:Blocked_Tor_exit_nodes" -O "wikipedia.txt"
wget "http://www.enn.lu/status/" -O "ennlu.txt"
wget --no-check-certificate "https://gitweb.torproject.org/tor.git/blob/HEAD:/src/or/config.c#l819" -O "gist.txt"
wget "http://rules.emergingthreats.net/blockrules/emerging-tor.rules" -O "ethreats.txt"
wget "http://hqpeak.com/torexitlist/free/?format=json" -O "hqpeak.txt"


# Batch 1: UKdan and German site
# Let's start working with, manipulating our files.
# These files are only a listing of IP addresses, so we do not need to do anything more at this time, 
# with these files.
for i in *.list; do
	cat $i >> tornodes_working_$TODAY
done

# Batch 2: Tor, wikipedia, ennlu, Github, ethreats, hqpeak
for i in *.txt; do
	cat $i | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' $list >> tornodes_working_$TODAY
done
#
# Our final set of processing is to go through our working list, and pull out any addresses, that are RFC 3330.
cat tornodes_working_$TODAY.txt | grep -E -v '(^127\.0\.0\.1)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)|(^0.)|(^169\.254\.)' | sort | uniq >> tornodes_ipv4_$TODAY

while read i; do
	echo "$i, " >> tornodes_siem_ipv4_$TODAY.csv;
	echo "ALL:    $i" >> tornodes_hostsdeny_$TODAY.deny
	echo "iptables -A INPUT -s $i -j DROP LOG --log-prefix 'feodo tracker' " >> tornodes_iptables_$TODAY.sh
	echo "iptables -A OUTPUT -s $i -j DROP LOG --log-prefix 'feodo tracker' " >> tornodes_iptables_$TODAY.sh
	echo "iptables -A FORWARD -s $i -j DROP LOG --log-prefix 'feodo tracker' " >> tornodes_iptables_$TODAY.sh
done < tornodes_ipv4_$TODAY
cp tornodes_iptables_$TODAY.sh /tmp/osint/rules/tornodes_iptables_$TODAY.sh
cp tornodes_hostsdeny_$TODAY.deny /tmmp/osint/rules/tornodes_hostsdeny_$TODAY.deny
cp tornodes_siem_ipv4_$TODAY.csv /tmp/osint/rules/tornodes_siem_ipv4_$TODAY.csv


#
# EOS


# This copyright notice is included for using the emerging threats rule.
#*************************************************************
#
#  Copyright (c) 2003-2013, Emerging Threats
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
#  following conditions are met:
#  
#  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
#    disclaimer.
#  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
#    following disclaimer in the documentation and/or other materials provided with the distribution.
#  * Neither the name of the nor the names of its contributors may be used to endorse or promote products derived 
#    from this software without specific prior written permission.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED WARRANTIES, 
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
#  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
#  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
#
#


#
# EOF

