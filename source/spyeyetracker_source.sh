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
if [ ! -d "/tmp/ossint/sources/spyeye" ]; then
        mkdir -p /tmp/osint/sources/spyeye;
fi
cd $HOME
datadirs=( ipv4 domains hashes rules )
for i in "${datadirs[@]}"; do
        if [ ! -d "$HOME/$i" ]; then
                mkdir -p $HOME/$i
        fi
done
cd $SOURCES/spyeye;
###################################
###### Get the bad domains:
wget --header="$HEADER" --user-agent="$UA21" https://spyeyetracker.abuse.ch/blocklist.php?download=domainblocklist -O spyeye_domain_$TODAY.txt
sleep 13;
###### Get the IP lists
wget --header="$HEADER" --user-agent="$UA21" https://spyeyetracker.abuse.ch/blocklist.php?download=ipblocklist -O spyeye_blocklist_$TODAY.txt
sleep 13;
wget --header="$HEADER" --user-agent="$UA22" https://spyeyetracker.abuse.ch/monitor.php?browse=binaries -O spyeye_binaries_$TODAY.txt
sleep 13;
wget --header="$HEADER" --user-agent="$UA22" https://spyeyetracker.abuse.ch/monitor.php?browse=configs -O spyeye_configs_$TODAY.txt
sleep 13;
wget --header="$HEADER" --user-agent="$UA22" https://spyeyetracker.abuse.ch/blocklist.php?download=squidblocklist -O spyeye_squid_$TODAY.txt
sleep 13;
wget --header="$HEADER" --user-agent="$UA22" https://spyeyetracker.abuse.ch/blocklist.php?download=iptablesblocklist -O spyeye_iptables_$TODAY.txt
sleep 13;
wget --header="$HEADER" --user-agent="$UA22" https://spyeyetracker.abuse.ch/blocklist.php?download=hostfile -O spyeye_hostsfile_$TODAY.txt
sleep 13;
wget --header="$HEADER" --user-agent="$UA22" https://spyeyetracker.abuse.ch/blocklist.php?download=hostsdeny -O spyeye_hostsdeny_$TODAY.txt


#
##### Move the files we are not going to modify
cat spyeye_squid_$TODAY.txt | sed '/^#/ d' >> /tmp/osint/rules/spyeye_squid_$TODAY.rules
cat spyeye_iptables_$TODAY.txt | sed '/^#/ d' >> /tmp/osint/rules/spyeye_iptables_$TODAY.txt
cat spyeye_hostsfile_$TODAY.txt | sed '/^#/ d' >>  /tmp/osint/rules/spyeye_hosts_$TODAY.txt
cat spyeye_hostsdeny_$TODAY.txt | sed '/^#/ d' >> /tmp/osint/rules/spyeye_hostdeny_$TODAY.deny
#
##### Some IP file stripping now
# Strip the Spyeye file now
for i in spyeye_*_$TODAY.txt; do
	cat $i | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' >> spyeye_ip_working.txt
	echo $i;
done
# Sort and remove any duplicates
cat spyeye_ip_working.txt | sort | uniq > spyeye_ipv4_$TODAY
cp spyeye_ipv4_$TODAY.txt /tmp/osint/ipv4/spyeye_ipv4_$TODAY.txt
#
# Make the SIEM IPv4 file now.
while read i; do
	echo "$i, " >> spyeye_siem_ipv4_$TODAY.csv
done < spyeye_ipv4_$TODAY.txt
cp spyeye_siem_ipv4_$TODAY.csv /tmp/osint/rules/spyeye_siem_ipv4_$TODAY.csv
#
#########################################
# Some domain file stripping now
sed '/^#/ d' spyeye_domain_$TODAY.txt >> spyeye_domain_master_$TODAY.txt
cp spyeye_domain_master_$TODAY /tmp/osint/domains/spyeye_domains_$TODAY.txt
#
# Make the SIEM domain file now.
while read i; do
	echo "$i, " >> spyeye_siem_domains_$TODAY.csv
done < spyeye_domain_master_$TODAY
cp spyeye_siem_domains_$TODAY.csv /tmp/osint/rules/spyeye_siem_domains_$TODAY.csv
#
#########################################
#
while read p; do
	wget --header="$HEADER" --user-agent="$UA22" https://spyeyetracker.abuse.ch/monitor.php?host=$p -O spyeye_hashes_$p.html
	sleep 13;
done < spyeye_ipv4_$TODAY.txt
#
# Spyeye domains now.
while read p; do
        wget --header="$HEADER" --user-agent="$UA22" https://spyeyetracker.abuse.ch/monitor.php?host=$p -O spyeye_hashes_$p.html
        sleep 13;
done < spyeye_domain_master_$TODAY.txt
#
# Now let's go through these files and only pull the information
# that we want for our OSINT project
for i in spyeye_hashes_*.html; do
	cat $i | grep -a -o -e "[0-9a-f]\{64\}" >> spyeye_hashes_sha256_$TODAY.txt
	cat $i | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' >> spyeye_ipv4_old_$TODAY.txt
	cat $i | sed -e 's/<\/\?a\s*[^>]*>//g' | grep -a -o -e "[0-9a-f]\{32\}" >> spyeye_hashes_md5_$TODAY.txt
done
#
# A new file to parse through for hashes.
cat spyeye_configs_$TODAY.html | grep -a -o -e "[0-9a-f]\{32\}" >> spyeye_hashes_md5_$TODAY.txt
#
#
cat spyeye_hashes_sha256_$TODAY.txt | sort | uniq >> spyeye_sha256_$TODAY.txt
cat spyeye_hashes_md5_$TODAY.txt | sort | uniq >> spyeye_md5_$TODAY.txt
cat spyeye_ipv4_old_$TODAY.txt | sort | uniq >> spyeye_ipv4_archive_$TODAY.txt
#
#
cp spyeye_sha256_$TODAY.txt /tmp/osint/hashes/spyeye_sha256_$TODAY.txt
cp spyeye_md5_$TODAY.txt /tmp/osint/hashes/spyeye_md5_$TODAY.txt
cp spyeye_ipv4_archive_$TODAY.txt /tmp/osint/ipv4/spyeye_ipv4_archive_$TODAY.txt

#
#####
#
# Clean up some old files.
tar zcf spyeye_hashes_$TODAY.tgz *.html
rm -rf *.html
#
# Move all of our files to a better location
cd /tmp/osint/rules
cp spyeye*.txt /home/osint/rules
cd /tmp/osint/hashes
cp *.txt /home/osint/hashes


#
# EOF
