#!/bin/bash
#
# update-botnetnodes.sh
# Matthew Ulm
# 2014-03-05
# This script will gather a listing of the Botnet CnC servers that are available from some of the free services, and it will gather them 
# all into a single CSV file, that can be uploaded into a SIEM, IDS, or some other network detection/ analysis device.
# Commands used:
# touch, mkdir, cd, echo, wget, cat, wc, grep, sort, uniq, zip, cp, mv, date, rm
#
# Let's get started:
# First create some files, and move around into a working directory.
mkdir botnetdir
cd botnetdir
touch workinglist.csv
touch botnetnodes.log
#
# Add some formatting for our log file.
echo "We are starting our collection at: $(date)" >> botnetnodes.log
echo "-----" >> botnetnodes.log
echo "-----" >> botnetnodes.log

#
# Let's get the our listings from the botnet monitor services.
echo "Let's get our IP listings" >> botnetnodes.log
echo "Homepage: https://spyeyetracker.abuse.ch/monitor.php" >> botnetnodes.log
wget http://www.abuse.ch/spyeyetracker/blocklist.php?download=ipblocklist -O spyeye.list
echo "-----" >> botnetnodes.log
echo "-----" >> botnetnodes.log
echo "We are going to grab the list now from the Zues tracker site." >> botnetnodes.log
echo "This list is actually a combination of three different botnet families" >> botnetnodes.log
echo "It will give us a listing of Zeus, IceX, and Citadel" >> botnetnodes.log
wget http://www.abuse.ch/zeustracker/blocklist.php?download=ipblocklist -O zeus.list
echo "-----" >> botnetnodes.log
echo "-----" >> botnetnodes.log
echo "This list is for the Palevo tracker." >> botnetnodes.log
wget --no-check-certificate https://palevotracker.abuse.ch/blocklists.php?download=ipblocklist -O palevo.list
echo "-----" >> botnetnodes.log
echo "-----" >> botnetnodes.log

#
# Declare an array of our lists, so we can loop through them. The loop will make sure that only valid IP addresses 
# are a part of our file. ONce they are validated, we will cat them into a larger file for use in other scripts.
declare -a botlist=('spyeye.list' 'zeus.list' 'palevo.list')
for list in "${botlist[@]}"
do :
	echo "$list" >> botnetnodes.log
	grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' $list >> workinglist.csv
	wc -l workinglist.csv >> botnetnodes.log
	echo "-----" >> botnetnodes.log
done

# let's sort some things, and make sure we do not have any duplicates. Then we will move our file ready to be 
# uploaded out of our working directory, then we will zip up our working directory, so we can save it for long 
# term storage.
sort workinglist.csv >> sortedlist.csv
uniq sortedlist.csv >> botnets.csv
cp botnets.csv ../
cp botnetnodes.log ../
cd ../
zip bots.zip botnetdir/*
mv bots.zip bots_daily_$(date +%F).zip
mv botnets.csv bots_daily_$(date +%F).csv
mv botnetnodes.log bots_daily_$(date +%F).log
rm -rf botnetdir

# EOS
# EOF