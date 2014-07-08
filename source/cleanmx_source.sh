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
if [ ! -d "/tmp/ossint/sources/cleanmx" ]; then
        mkdir -p /tmp/osint/sources/cleanmx;
fi
cd $HOME
datadirs=( ipv4 domains hashes rules )
for i in "${datadirs[@]}"; do
        if [ ! -d "$HOME/$i" ]; then
                mkdir -p $HOME/$i
        fi
done
#####################################
cd $SOURCES/cleanmx
# Grab some files form the internet
wget --user-agent="$UA22" "http://support.clean-mx.de/clean-mx/viruses" -O cleanmx_virus1_$TODAY.txt
sleep 13;
wget --user-agent="$UA22" "http://support.clean-mx.de/clean-mx/phishing.php" -O cleanmx_phishing_$TODAY.txt
sleep 13;
wget --user-agent="$UA22" "http://support.clean-mx.de/clean-mx/portals.php" -O cleanmx_defaced_$TODAY.txt
sleep 13;
wget --user-agent="$UA21" "http://support.clean-mx.de/clean-mx/viruses.php" -O cleanmx_virus2_$TODAY.txt
#
#####
# Let's grab some IP addresses from this file.
for i in  cleanmx_vir*_$TODAY.txt ; do
	cat $i | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' >> cleanmx_ipv4_malware_working.txt;
	cat $i | grep "follow up this domain (" | awk -F "[()]" '{ for (i=2; i<NF; i+=2) print $i }' >> cleanmx_domains_malware_working.txt
done
cat cleanmx_ipv4_malware_working.txt | sort | uniq >> cleanmx_ipv4_malware_$TODAY.txt
cp cleanmx_ipv4_malware_$TODAY.txt /tmp/osint/ipv4/cleanmx_ipv4_malware_$TODAY.txt
cat cleanmx_domains_malware_working.txt | sort | uniq >> cleanmx_domains_malware_$TODAY.txt
cp cleanmx_domains_malware_$TODAY.txt /tmp/osint/domains/cleanmx_domains_malware_$TODAY.txt
#
#####
#
cat cleanmx_phishing_$TODAY.txt | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' | sort | uniq >> cleanmx_ipv4_phishing_$TODAY.txt
cat cleanmx_phishing_$TODAY.txt | grep "follow up this domain (" | awk -F "[()]" '{ for (i=2; i<NF; i+=2) print $i }' >> cleanmx_domains_phishing_working_$TODAY.txt
cp cleanmx_ipv4_phishing_$TODAY.txt /tmp/osint/ipv4/cleanmx_ipv4_phishing_$TODAY.txt
cat cleanmx_domains_phishing_working_$TODAY.txt | sort | uniq >> cleanmx_domains_phishing_$TODAY.txt
cp cleanmx_domains_phishing_$TODAY.txt /tmp/osint/domains/cleanmx_domains_phishing_$TODAY.txt
#
#####
#
cat cleanmx_defaced_$TODAY.txt | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' | sort | uniq >> cleanmx_ipv4_defaced_$TODAY.txt
cat cleanmx_defaced_$TODAY.txt | grep "follow up this domain (" | awk -F "[()]" '{ for (i=2; i<NF; i+=2) print $i }' >> cleanmx_domains_defaced_$TODAY.txt
cp cleanmx_ipv4_defaced_$TODAY.txt /tmp/osint/ipv4/cleanmx_ipv4_defaced_$TODAY.txt
cp cleanmx_domains_defaced_$TODAY.txt /tmp/osint/domains/cleanmx_domains_defaced_$TODAY.txt
#
#

#
#####
#
# Start the Windows Host File
cat cleanmx_domains_malware_$TODAY.txt cleanmx_hosts_working_$TODAY.txt
cat cleanmx_domains_phishing_$TODAY.txt cleanmx_hosts_working_$TODAY.txt
cat cleanmx_hosts_working_$TODAY.txt | sort | uniq >> cleanmx_hosts_sort_$TODAY.txt
while read i; do
        echo "127.0.0.1     www.$i, $i "; >> cleanmx_hosts_$TODAY.txt
done < cleanmx_hosts_sort_$TODAY.txt
cp cleanmx_hosts_sort_$TODAY.txt /tmp/osint/rules/cleanmx_hosts_$TODAY.txt
#
#####
#
# Start the SIEM Files
cat cleanmx_domains_malware_$TODAY.txt cleanmx_siem_working_$TODAY.txt
cat cleanmx_domains_phishing_$TODAY.txt cleanmx_siem_working_$TODAY.txt
cat cleanmx_domains_defaced_$TODAY.txt cleanmx_siem_working_$TODAY.txt
cat cleanmx_siem_working_$TODAY.txt | sort | uniq >> cleanmx_siem_$TODAY.txt
while read i; do
        echo "$i," >> cleanmx_siem_domains_$TODAY.txt
done < cleanmx_siem_$TODAY.txt
cp cleanmx_siem_domains_$TODAY.txt /tmp/osint/rules/cleanmx_siem_domains_$TODAY.txt
#
while read i; do
	echo "$i," >> cleanmx_siem_ipv4_$TODAY.txt
done < cleanmx_ipv4_malware_$TODAY.txt
cp cleanmx_siem_ipv4_$TODAY.txt /tmp/osint/rules/cleanmx_siem_ipv4_$TODAY.txt
#
#####
#


#
# EOF
