#!/bin/bash
#####
# Description: Some information about the source
#
# Name: Malc0de Database
# Host: 
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
if [ ! -d "/tmp/ossint/sources/malc0de" ]; then
        mkdir -p /tmp/osint/sources/malc0de;
fi
cd $HOME
datadirs=( ipv4 domains hashes rules )
for i in "${datadirs[@]}"; do
        if [ ! -d "$HOME/$i" ]; then
                mkdir -p $HOME/$i
        fi
done
#####################################
cd /tmp/osint/sources/malc0de;
wget --header="$HEADER" --user-agent="$UA21" "http://malc0de.com/bl/BOOT" -O "c0de_domain_blocklist_$TODAY.txt"
sleep 1;
wget --header="$HEADER" --user-agent="$UA22" "http://malc0de.com/bl/IP_Blacklist.txt" -O "c0de_ipv4_blocklist_$TODAY.txt"
sleep 13;
wget --header="$HEADER" --user-agent="$UA21" "http://malc0de.com/database/" -O "c0de_db1_$TODAY.txt" 
sleep 16;
wget --header="$HEADER" --user-agent="$UA22" "http://malc0de.com/database/?&page=2" -O "c0de_db2_$TODAY.txt"
sleep 19;
wget --header="$HEADER" --user-agent="$UA21" "http://malc0de.com/database/?&page=3" -O "c0de_db3_$TODAY.txt"
#
######################################################
# OK, let's sort through some files and pull our IPv4 
# information, and then compile it all together.
for i in *.txt; do
	cat $i | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' >> malc0de_ipv4_working.txt
	cat $i | grep -a -o -e "[0-9a-f]\{32\}" >> malc0de_md5_working.txt
done
cat malc0de_ipv4_working.txt | sed '/^#/ d' |  sed '/^// d' | sort | uniq >> malc0de_ipv4_$TODAY.txt
cp malc0de_ipv4_$TODAY.txt /tmp/osint/ipv4/malc0de_ipv4_$TODAY.txt
while read i; do
	echo "$i, " >> malc0de_siem_ipv4_$TODAY.csv
	echo "ALL:    $i" >> malc0de_hostsdeny_$TODAY.deny
	echo "iptables -A INPUT -s $i -j DROP LOG --log-prefix 'malc0de_DB' " >> malc0de_iptables_$TODAY.sh
	echo "iptables -A OUTPUT -s $i -j DROP LOG --log-prefix 'malc0de_DB' " >> malc0de_iptables_$TODAY.sh
	echo "iptables -A FORWARD -s $i -j DROP LOG --log-prefix 'malc0de_DB' " >> malc0de_iptables_$TODAY.sh
done < malc0de_ipv4_$TODAY.txt
cp malc0de_iptables_$TODAY.sh /tmp/osint/rules/malc0de_iptables_$TODAY.sh
cp malc0de_siem_ipv4_$TODAY.csv /tmp/osint//rules/malc0de_siem_ipv4_$TODAY.csv
#
#
######
# Set up the hosts file for Windows.
cat c0de_domain_blocklist_$TODAY.txt | awk -F ' ' '{print $2}' >> domain_hosts_working_$TODAY.txt
# Filter out some domains that always seem to show up.
domains1=(sun.com google.com baidu.com google.com googleapis.com tinyurl.com )
domainsedelman=(edelman.com edelmandigital.com)
cat domain_hosts_working_$TODAY.txt | grep -v "sun.com" | grep -v "googleapis.com" | grep -v "google.com" | grep -v "edelman.com" >> domain_hosts_filter_$TODAY.txt
cp domain_hosts_filter_$TODAY.txt domain_hosts_$TODAY.txt
#
while read i; do
	echo "127.0.0.1     www.$i $i " >> malc0de_hosts_$TODAY.txt
	echo "$i, " >> malc0de_siem_domains_$TODAY.csv
	echo "ALL:    .$i" >> malc0de_hostsdeny_$TODAY.deny
done < domain_hosts_$TODAY.txt 
cp malc0de_hosts_$TODAY.txt /tmp/osint/rules/malc0de_hosts_$TODAY.txt
cp malc0de_hostsdeny_$TODAY.deny /tmp/osint/rules/malc0de_hostsdeny_$TODAY.deny
cp malc0de_siem_domains_$TODAY.csv /tmp/osint/rules/malc0de_siem_domains_$TODAY.csv
#
###########################################################
# Grab some MD5 hashes from the files while we are at it
while read i; do
        # malc0de
        echo " Checking the malc0de database for ..... $i"
        wget "http://malc0de.com/database/index.php?search=$i" -O "malc0de_md5_$i.html"
        sleep 20;
        echo " "
done < malc0de_ipv4_working.txt
#find /tmp/osint/sources/malc0de -mtime +1 -type f -delete
for i in malc0de_md5_*.html; do
	cat $i | grep -a -o -e "[0-9a-f]\{32\}" >> malc0de_md5_working.txt
done
cat malc0de_md5_working.txt | sort | uniq >> malc0de_md5_$TODAY.txt
cp malc0de_md5_$TODAY.txt /tmp/osint/hashes/malc0de_md5_$TODAY.txt
#
#
#####
# Clean Up
tar zcf malc0de_html_$TODAY.tgz *.html
rm -rf *.html


#
# EOF
