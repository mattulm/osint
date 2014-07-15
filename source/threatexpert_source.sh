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
if [ ! -d "/tmp/ossint/sources/threatexpert" ]; then
        mkdir -p /tmp/osint/sources/threatexpert;
fi
cd $HOME
datadirs=( ipv4 domains hashes rules )
for i in "${datadirs[@]}"; do
        if [ ! -d "$HOME/$i" ]; then
                mkdir -p $HOME/$i
        fi
done
#####################################
cp $SOURCES/threatexpert
wget --header="$HEADER" --user-agent="$UA21" http://www.threatexpert.com/ -O "threatexpert_home.html"
cat threatexpert_home.html | sed 's/.*"\(.*\)"[^"]*$/\1/' | grep "reports.aspx" >> "threatexpert_reports_$TODAY.txt"
sleep 24;
for i in {1..10}; do
	wget --header="$HEADER" --user-agent="$UA22" http://www.threatexpert.com/reports.aspx?page=$i -O "threatexpert_reports_$i.html"
	sleep 16;
done
sleep 14;
for i in threatexpert_reports_$TODAY.txt; do
	counter=1
		wget --hreader="$HEADER" --user-agent="$UA21" http://www.threatexpert.com/$i -O "threatexpert_reports_$counter.html"
	let counter=counter+1;
done


#
#####
for i in *.html; do
	cat $i | grep -a -o -e "[0-9a-f]\{32\}" >> threatexpert_md5_working_$TODAY.txt
done
cat threatexpert_md5_working_$TODAY.txt | sort| uniq >> threatexpert_md5_$TODAY.txt
cp threatexpert_md5_$TODAY.txt /tmp/osint/hashes/threatexpert_md5_$TODAY.txt
