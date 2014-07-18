#!/bin/bash
#####
# Description: Some information about the source
# Name: DSHield
# Frequency: Daily
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
wget --no-check-certificate --header="$HEADER" --user-agent="$UA22" https://www.dshield.org/ipsascii.html?limit=1000 -O "dshield_ipsascii_$TODAY.txt"
sleep 7;
wget --no-check-certificate --header="$HEADER" --user-agent="$UA22" https://isc.sans.edu/feeds/suspiciousdomains_Medium.txt -O "dshield_domains_working_$TODAY.txt"
sleep 15;
wget --no-check-certificate --header="$HEADER" --user-agent="$UA22" https://isc.sans.edu/feeds/suspiciousdomains_High.txt -O "dshield_hostfile_working_$TODAY.txt"
sleep 13;
wget --no-check-certificate --header="$HEADER" --user-agent="$UA22" https://isc.sans.edu/block.txt -O "dshield_netblocks_$TODAY.txt"
cp dshield_netblocks_$TODAY.txt /tmp/osint/rules/dshield_netblocks_$TODAY.txt
#
#####
#
cat dshield_ipsascii_$TODAY.txt | sed '/^#/ d' | sed 's/\.0\{1,2\}/\./g' | sed 's/^0\{1,2\}//' | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' | sort | uniq >> dshield_ipv4_master_$TODAY.txt
cp dshield_ipv4_master_$TODAY.txt /tmp/osint/ipv4/dshield_ipv4_$TODAY.txt
#
# Start some files
while read i; do
	echo "$i, " >> dshield_siem_ipv4_$TODAY.csv;
	echo "ALL:    $i" >> dshield_hostsdeny_$TODAY.deny
	echo "iptables -A INPUT -s $i -j DROP LOG --log-prefix 'SANS DShield' " >> dshield_iptables_$TODAY.sh
	echo "iptables -A OUTPUT -s $i -j DROP LOG --log-prefix 'SANS DShield' " >> dshield_iptables_$TODAY.sh
	echo "iptables -A FORWARD -s $i -j DROP LOG --log-prefix 'SANS DShield' " >> dshield_iptables_$TODAY.sh
done < dshield_ipv4_master_$TODAY.txt
#
cp dshield_iptables_$TODAY.sh /tmp/osint/rules/dshield_iptables_$TODAY.sh
cp dshield_siem_ipv4_$TODAY.csv /tmp/osint/rules/dshield_siem_ipv4_$TODAY.csv
#
#####
cat dshield_domains_working_$TODAY.txt | sed '/^#/ d' >> dshield_domains_working.txt
cat dshield_hostfile_working_$TODAY.txt | sed '/^#/ d' >> dshield_domains_working.txt
cat dshield_domains_working.txt | sort | uniq >> dshield_domains_$TODAY.txt
while read i; do
        echo "127.0.0.1    www.$i $i" >> dshield_hostfile_$TODAY.txt
	echo "$i, " >> dshield_siem_domains_$TODAY.csv
	echo "ALL:    .$i" >> dshield_hostsdeny_$TODAY.deny
done < dshield_domains_$TODAY.txt
cp dshield_hostfile_$TODAY.txt /tmp/osint/rules/dshield_host_$TODAY.txt
cp dshield_siem_domains_$TODAY.csv /tmp/osint/rules/dshield_siem_domains_$TODAY.csv
cp dshield_hostsdeny_$TODAY.deny /tmp/osint/rules/dshield_hostsdeny_$TODAY.deny


#
#####
# Clean Up
rm -rf dshield_domains_working.txt
#
# EOF
