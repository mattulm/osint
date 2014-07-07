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
if [ ! -d "/tmp/ossint/sources/zeus" ]; then
        mkdir -p /tmp/osint/sources/zeus;
fi
cd $HOME
datadirs=( ipv4 domains hashes rules )
for i in "${datadirs[@]}"; do
        if [ ! -d "$HOME/$i" ]; then
                mkdir -p $HOME/$i
        fi
done
cd $SOURCES/zeus;
#####################################
###### Get the IDS/IPS rules first
wget --header="$HEADER" --user-agent="$UA21" https://zeustracker.abuse.ch/blocklist.php?download=snort -O zeus_snort_$TODAY.rules
sleep 13;
cp zeus_snort_$TODAY.rules /tmp/osint/rules/zeus_snort_$TODAY.rules
###### Get the bad domains:
wget --header="$HEADER" --user-agent="$UA21" https://zeustracker.abuse.ch/blocklist.php?download=baddomains -O zeus_domain_$TODAY.txt
sleep 13;
# Zeus Tracker
wget --header="$HEADER" --user-agent="$UA21" https://zeustracker.abuse.ch/blocklist.php?download=badips -O zeus_blocklist_$TODAY.txt
sleep 13;
wget --header="$HEADER" --user-agent="$UA21" https://zeustracker.abuse.ch/statistic.php -O zeus_stats_$TODAY.txt
sleep 13;
wget --header="$HEADER" --user-agent="$UA22" https://zeustracker.abuse.ch/monitor.php?browse=binaries -O zeus_binaries_$TODAY.txt
sleep 13;
wget --header="$HEADER" --user-agent="$UA22" https://zeustracker.abuse.ch/monitor.php?browse=binaries -O zeus_binaries_$TODAY.txt
#####


#######################################
##### Some IP file stripping now
# Strip the zeus file now
for i in zeus_*_$TODAY; do
	cat $i  | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' >> zeus_ip_working.txt
done
cat zeus_ip_working.txt | sort | uniq >> zeus_ip_$TODAY.txt
cp zeus_ip_$TODAY.txt /tmp/osint/ipv4/zeus_ipv4_$TODAY.txt

####################################################
# Some domain file stripping now. This will remove
# any line that startes with the comment character.
sed '/^#/ d' zeus_domain_$TODAY.txt >> zeus_domain_$TODAY.txt
cp zeus_domain_$TODAY.txt /tmp/osint/domains/zeus_domain_$TODAY.txt


#########################################
# Get some Hashes
cat zeus_stats_$TODAY.txt | grep -a -o -e "[0-9a-f]\{32\}" >> zeus_md5_working.txt
cat zeus_binaries_$TODAY.txt | grep -a -o -e "[0-9a-f]\{32\}" >> zeus_md5_working.txt
# Now the IPv4 addresses
while read p; do
	wget --header="$HEADER" --user-agent="$UA22" https://zeustracker.abuse.ch/monitor.php?host=$p -O zeus_hashes_$p.html
done < zeus_ip_$TODAY.txt
# Now the domains
while read p; do
        wget --header="$HEADER" --user-agent="$UA22" https://zeustracker.abuse.ch/monitor.php?host=$p -O zeus_hashes_$p.html
done < zeus_domain_$TODAY.txt
#####
for i in zeus_hashes_*.html; do
	cat $i | grep -a -o -e "[0-9a-f]\{32\}" >> zeus_md5_working.txt
done
####
cat zeus_md5_working.txt | sort | uniq >> zeus_md5_master_$TODAY.txt
cp zeus_md5_master_$TODAY.txt /tmp/osint/hashes/zeus_md5_$TODAY.txt

#
# EOF
