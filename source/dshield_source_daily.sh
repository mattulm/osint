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
if [ ! -d "/tmp/ossint/sources/dshield" ]; then
        mkdir -p /tmp/osint/sources/dshield;
fi
cd $HOME
datadirs=( ipv4 domains hashes rules )
for i in "${datadirs[@]}"; do
        if [ ! -d "$HOME/$i" ]; then
                mkdir -p $HOME/$i
        fi
done
cd $SOURCES/dshield
###########################################################
wget --no-check-certificate --header="$HEADER" --user-agent="$UA22" https://www.dshield.org/ipsascii.html?limit=1000 -O dshield_ipsascii_$TODAY.txt
sleep 13;
wget --no-check-certificate --header="$HEADER" --user-agent="$UA22" https://isc.sans.edu/feeds/suspiciousdomains_Medium.txt -O dshield_domains_working_$TODAY.txt
sleep 15;
wget --no-check-certificate --header="$HEADER" --user-agent="$UA22" https://isc.sans.edu/feeds/suspiciousdomains_High.txt -O dshield_hostfile_$TODAY.txt
sleep 13;
wget --no-check-certificate --header="$HEADER" --user-agent="$UA22" https://isc.sans.edu/block.txt -O dshield_netblocks_$TODAY.txt


cat dshield_ipsascii_$TODAY.txt | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' >> dshield_ip_working.txt
cat dshield_ip_working.txt | sort | uniq >> dshield_ipv4_master_$TODAY.txt
cp dshield_ipv4_master_$TODAY.txt /tmp/osint/ipv4/dshield_ipv4_$TODAY.txt
#
#
cat dshield_domains_working_$TODAY.txt | sed '/^#/ d' >> dshield_domains_$TODAY.txt
cp dshield_domains_$TODAY.txt /tmp/osint/domains/dshield_domains_$TODAY.txt
cp dshield_domains_$TODAY.txt /tmp/osint/rules/dshiel/siem/$TODAY.txt
#
#
cat dshield_hostfile_working_$TODAY.txt | sed '/^#/ d' >> dshield_hostfile_stripped_$TODAY.txt
while read i; do
        echo "127.0.0.1    $i" >> dshield_hostfile_$TODAY.txt
done < dshield_hostfile_stripped_$TODAY.txt
cp dshield_hostfile_$TODAY.txt /tmp/osint/rules/dshield_host_$TODAY.txt
cp dshield_netblocks_$TODAY.txt /tmp/osint/ipv4/dshield_netblocks_$TODAY.txt


#
# EOF
