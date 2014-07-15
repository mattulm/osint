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
if [ ! -d "/tmp/ossint/sources/malwrcom" ]; then
        mkdir -p /tmp/osint/sources/malwrcom;
fi
cd $HOME
datadirs=( ipv4 domains hashes rules )
for i in "${datadirs[@]}"; do
        if [ ! -d "$HOME/$i" ]; then
                mkdir -p $HOME/$i
        fi
done
#####################################
cp $SOURCES/malwrcom
wget --header="$HEADER" --user-agent="$UA22" "https://malwr.com/" -O "malwrcom_homepage_$TODAY_.html"
sleep 13;
for i in (1..10); do
	wget --header="$HEADER" --user-agent="$UA21" "https://malwr.com/analysis/?page=$i" "malwarcom_analysis_$i.html"
done

cat malwrcom_homepage_$TODAY_.html | 


#
# Pull soem hashes
for i in *.html; do
	cat $i | grep -a -o -e "[0-9a-f]\{32\}" >> malwrcom_md5_working_$TODAY.txt
done
cat malwrcom_md5_working_$TODAY.txt | sort | uniq >> malwrcom_md5_$TODAY.txt

