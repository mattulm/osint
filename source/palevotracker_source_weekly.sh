#!/bin/bash
###################################################
# Description: Some information about the source
#
# Name: Palevo Bot TRacker
# Host: Abuse.ch (The Swiss Security Blog.)
# Frequency: Daily
# Types: IPv4, domain, hashes
# Some Variables
HOME="/tmp/osint"
SOURCES="/tmp/osint/sources"
HEADER="Accept: text/html"
UA21="Mozilla/5.0 Gecko/20100101 Firefox/21.0"
UA22="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13; ) Gecko/20101203"
TODAY=$(date +"%Y-%m-%d")
if [ ! -d "/tmp/ossint/sources/palevo" ]; then
        mkdir -p /tmp/osint/sources/palevo;
fi
datadirs=( ipv4 domains hashes rules )
for i in "${datadirs[@]}"; do
        if [ ! -d "$HOME/$i" ]; then
                mkdir -p $HOME/$i
        fi
done
cd $SOURCES/palevo
###################################################
# Get the bad domains:
wget --header="$HEADER" --user-agent="$UA21" https://palevotracker.abuse.ch/blocklists.php?download=domainblocklist -O palevo_domain_$TODAY.txt
sleep 13;
# Get the IP lists
wget --header="$HEADER" --user-agent="$UA21" https://palevotracker.abuse.ch/blocklists.php?download=ipblocklist -O palevo_blocklist_$TODAY.txt
sleep 13;
wget --header="$HEADER" --user-agent="$UA21" https://palevotracker.abuse.ch/?statistic -O palevo_stats_$TODAY.txt
sleep 13;
#
#
# Some IP file stripping now
for f in palevo_*_$TODAY.txt; do
        cat $f | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' >> palevo_ip_working.txt
done
#
# Need to strip the Feodo domain list. This will
# remove the comment character and any line that 
# starts with that character.
sed '/^#/ d' palevo_domain_$TODAY.txt >> palevo_domain_master_$TODAY.txt
sed '/^#/ d' palevo_blocklist_$TODAY.txt >> palevo_blocklist_master_$TODAY.txt
cp palevo_domain_master_$TODAY.txt /tmp/osint/domains/palevo_domains_$TODAY.txt
cp palevo_blocklist_master_$TODAY /tmp/osint/ipv4/palevo_ipv4_$TODAY.txt
#
# Get some Hashes
while read p; do
        wget --header="$HEADER" --user-agent="$UA22" https://palevotracker.abuse.ch/?host=$p -O palevo_hashes_$p.html
        sleep 13;
done < palevo_blocklist_master_$TODAY.txt
#####
while read p; do
        wget --header="$HEADER" --user-agent="$UA22" https://palevotracker.abuse.ch/?host=$p -O palevo_hashes_$p.html
        sleep 13;
done < palevo_domain_master_$TODAY.txt
# Let's combine these two
####################################################
# First pass to get only the hashes. 
# This is for SHA 256
for i in palevo_hashes_*.html; do
	cat $i | awk 'match($0,"td")' | grep -a -o -e "[0-9a-f]\{64\}" >> palevo_hashes_work_sha256_$TODAY.txt
	cat $i | sed -e 's/<\/\?a\s*[^>]*>//g' | grep -a -o -e "[0-9a-f]\{32\}" >> palevo_hashes_work_md5_$TODAY.txt
	cat $i | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' >> palevo_ipold_$TODAY.txt
done
# Sort and make sure we only keep uniq values
cat palevo_hashes_work_sha256_$TODAY.txt | sort | uniq >> palevo_sha256_$TODAY
cat palevo_hashes_work_md5_$TODAY.txt | sort | uniq >> palevo_md5_$TODAY
cp palevo_sha256_$TODAY /tmp/osint/hashes/palevo_sha256_$TODAY
cp palevo_md5_$TODAY /tmp/osint/hashes/palevo_md5_$TODAY
#
#
cat palevo_blocklist_master_$TODAY >> palevo_ipold_$TODAY.txt
cat palevo_ipold_$TODAY.txt | sort | uniq >> palevo_ipv4_archive_$TODAY.txt
cp palevo_ipv4_archive_$TODAY.txt /osint/ipv4/palevo_ipv4_archive_$TODAY.txt


#
# EOF
