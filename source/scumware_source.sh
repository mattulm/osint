#!/bin/bash
#####
# Description: Some information about the source
#
# Name: Scumware
# Frequency: Daily
# Types: IPv4, domain
#####
# Some Variables
HOME="/tmp/osint"
SOURCES="/tmp/osint/sources"
HEADER="Accept: text/html"
UA21="Mozilla/5.0 Gecko/20100101 Firefox/21.0"
UA22="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13; ) Gecko/20101203"
TODAY=$(date +"%Y-%m-%d")
if [ ! -d "/tmp/ossint/sources/scumware" ]; then
        mkdir -p /tmp/osint/sources/scumware;
fi
cd $HOME
datadirs=( ipv4 domains hashes rules )
for i in "${datadirs[@]}"; do
        if [ ! -d "$HOME/$i" ]; then
                mkdir -p $HOME/$i
        fi
done
#####################################
cd $SOURCES/scumware;
#
# Grab our initial list
wget --header="$HEADER" --user-agent="$UA21" "http://www.scumware.org" -O scumware_homepage_$TODAY.txt
sleep 13;
cat scumware_homepage_$TODAY.txt | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' | sort | uniq >> scumware_ipv4_working
#
# Now the IPv4 addresses
while read p; do
        wget --header="$HEADER" --user-agent="$UA22" "http://www.scumware.org/report/$p.html" -O scumware_report_$p.html
	sleep 19;
done < scumware_ipv4_working
#
# Now that we got these let's grab some information from them.
for i in scumware_report_*.html; do
	cat $i | grep -a -o -e "[0-9a-f]\{32\}" >> scumware_md5_$TODAY.txt
done

#
# Move Final IP file to folder
cat scumware_ipv4_working | sort | uniq >> scumware_ipv4_$TODAY.txt
cp scumware_ipv4_$TODAY.txt /tmp/osint/ipv4/scumware_ipv4_$TODAY.txt



#
# EOF
