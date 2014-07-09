#!/bin/bash
##################################################
# Description: Some information about the source
#
# Name: Feodo Bot TRacker
# Types: IPv4, domain, MD5, sha256
# Some Variables
HOME="/tmp/osint"
SOURCES="/tmp/osint/sources"
HEADER="Accept: text/html"
UA21="Mozilla/5.0 Gecko/20100101 Firefox/21.0"
UA22="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13; ) Gecko/20101203"
TODAY=$(date +"%Y-%m-%d")
if [ ! -d "/tmp/ossint/sources/feodo" ]; then
	mkdir -p /tmp/osint/sources/feodo;
fi
datadirs=( ipv4 domains hashes rules )
for i in "${datadirs[@]}"; do
	if [ ! -d "$HOME/$i" ]; then
		mkdir -p $HOME/$i
	fi
done
cd $SOURCES/feodo
##################################################
# Get the IDS/IPS rules first
wget --no-check-certificate --header="$HEADER" --user-agent="$UA21" "https://feodotracker.abuse.ch/blocklist/?download=snort" -O feodo_snort_$TODAY.rules
sleep 8;
wget --no-check-certificate --header="$HEADER" --user-agent="$UA21" "https://feodotracker.abuse.ch/blocklist/?download=suricata" -O feodo_suricatta_$TODAY.rules
sleep 11;
###### Get the bad domains:
wget --no-check-certificate --header="$HEADER" --user-agent="$UA21" "https://feodotracker.abuse.ch/blocklist/?download=domainblocklist" -O feodo_domain_working_$TODAY.txt
sleep 13;
###### Get the IP lists
wget --no-check-certificate --header="$HEADER" --user-agent="$UA21" "https://feodotracker.abuse.ch/blocklist/?download=ipblocklist" -O feodo_blocklist_$TODAY.txt
sleep 7;
wget --no-check-certificate --header="$HEADER" --user-agent="$UA21" "https://feodotracker.abuse.ch/blocklist/?download=badips" -O feodo_verB_$TODAY.txt
sleep 14;
wget --no-check-certificate --header="$HEADER" --user-agent="$UA22" "https://feodotracker.abuse.ch/" -O feodo_homepage_$TODAY.txt
##################################################
# Move the IDS/IPS rules
cp feodo_snort_$TODAY.rules /tmp/osint/rules/feodo_snort_$TODAY.rules;
cp feodo_suricatta_$TODAY.rules /tmp/osint/rules/feodo_suricatta_$TODAY.rules;
#
# Some IP file stripping now. I am going to go 
# through all of the files just in case 
for f in feodo_*_$TODAY.txt; do
        cat $f | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' >> feodo_ip_working.txt
done
#
# sort and remove some duplicates.
cat feodo_ip_working.txt | sort | uniq >> feodo_ipv4_$TODAY.txt
cp feodo_ipv4_$TODAY.txt /tmp/osint/ipv4/feodo_ipv4_$TODAY.txt;
#
# Some domain file stripping now. This will strip each line
# that begins with the comment character off of the file.
sed '/^#/ d' feodo_domain_working_$TODAY.txt | sort | uniq >> feodo_domain_master_$TODAY.txt
cp feodo_domain_master_$TODAY.txt /tmp/osint/domains/feodo_domains_$TODAY.txt
cat feodo_domain_master_$TODAY.txt | awk -F. '{ if ($(NF-1) == "co") printf $(NF-2)"."; printf $(NF-1)"."$(NF)"\n";}' >> feodo_domain_stripped_$TODAY.txt
#
#
# Make the Windows host file, the SIEM domain file, start the hosts.deny file.
echo "# feodo_hosts_$TODAY.txt" >> feodo_hosts_$TODAY.txt
echo "# feodo_hostsdeny_$TODAY.deny" >> feodo_hostsdeny_$TODAY.deny
while read i; do
	echo "127.0.0.1     www.$i, $i" >> feodo_hosts_$TODAY.txt;
	echo "$i, " >> feodo_siem_domains_$TODAY.csv
	echo "ALL:    .$i" >> feodo_hostsdeny_$TODAY.deny
done < feodo_domain_stripped_$TODAY.txt
cp feodo_hosts_$TODAY.txt /tmp/osint/rules/feodo_hosts_$TODAY.txt
cp feodo_siem_domains_$TODAY.csv /tmp/osint/rules/feodo_siem_domains_$TODAY.csv
#
#
# Make the SIEM IPv4 File, finish hosts.deny, and do the iptables file.
while read i; do
	echo "$i, " >> feodo_siem_ipv4_$TODAY.csv;
	echo "ALL:    $i" >> feodo_hostsdeny_$TODAY.deny
	echo "iptables -A INPUT -s $i -j DROP LOG --log-prefix 'feodo tracker' " >> feodo_iptables_$TODAY.sh
	echo "iptables -A OUTPUT -s $i -j DROP LOG --log-prefix 'feodo tracker' " >> feodo_iptables_$TODAY.sh
	echo "iptables -A FORWARD -s $i -j DROP LOG --log-prefix 'feodo tracker' " >> feodo_iptables_$TODAY.sh
done < feodo_ipv4_$TODAY.txt
cp feodo_siem_ipv4_$TODAY.csv /tmp/osint/rules/feodo_siem_ipv4_$TODAY.csv
cp feodo_hostsdeny_$TODAY.deny /tmp/osint/rules/feodo_hostsdeny_$TODAY.deny
cp feodo_iptables_$TODAY.sh /tmp/osint/rules/feodo_iptables_$TODAY.sh
#
#
##################################################
# Now the IPv4 addresses
while read p; do
        wget --no-check-certificate --header="$HEADER" --user-agent="$UA22" "https://feodotracker.abuse.ch/host/$p/" -O feodo_hashes_$p.html
   	sleep 17;
done < feodo_ipv4_$TODAY.txt
#
# Now the domains
while read p; do
        wget --no-check-certificate --header="$HEADER" --user-agent="$UA21" "https://feodotracker.abuse.ch/host/$p/" -O feodo_hashes_$p.html
	sleep 17;
done < feodo_domain_master_$TODAY.txt
#
# Let's work with these files and only pull out the hashes.
for i in *.html; do 
	cat $i | sed -e 's/^.*FF8000 //g;s/ width.*$//g' | grep -a -o -e "[0-9a-f]\{32\}" >> feodo_md5_working.txt
	cat $i | grep -a -o -e "[0-9a-f]\{64\}" >> feodo_sha256_working.txt
	cat $i | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' >> feodo_ipv4_old.txt
done
#
### 
cat feodo_md5_working.txt | sort | uniq >> feodo_md5_$TODAY.txt
cp feodo_md5_$TODAY.txt /tmp/osint/hashes/feodo_md5_$TODAY.txt
#
cat feodo_sha256_working.txt | sort | uniq >> feodo_sha256_$TODAY.txt
cp feodo_sha256_$TODAY.txt /tmp/osint/hashes/feodo_sha256_$TODAY.txt
#
cat feodo_ipv4_$TODAY.txt >> feodo_ipv4_old.txt
cat feodo_ipv4_old.txt | sort | uniq >> feodo_ipv4_archive_$TODAY.txt

#
#####
#
# Clean up some old files.
tar zcf feodo_hashes_$TODAY.tgz *.html
rm -rf *.html
#
# Move all of our files to a better location
cd /tmp/osint/rules
cp feodo*.txt /home/osint/rules
cd /tmp/osint/hashes
cp *.txt /home/osint/hashes

#
# EOF
