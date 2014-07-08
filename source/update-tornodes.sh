#!/bin/bash
#
# update-tornodes.sh
# Matthew Ulm
# 2014-03-05
# This script will gather a listing of the TOR node IPs and will merge them
# all into a single CSV file, that can be uploaded into a SIEM, IDS, or other
# network detection/ analysis device.
#
# Commands used:
# touch, echo, wget, cat, wc, grep, sort, uniq, zip, cp, mv, date
#
# TO DO:
# check the 5'th, 10'th and 11'th lists to see if they are back online.
# At this time they are either blocking or have gone off line.
# the 11'th can tell I am a script, so will need to work around that.
# 5: http://tornode.webatu.com/
# 10: http://blog.bannasties.com/2013/04/ips-blocked-as-tor-exit-nodes/
# 11: http://proxy.org/proxies_sorted2.shtml
#
# let's get started
# create our working files and directories, and then move into there for the remainder of the script.
mkdir tornodes
cd tornodes
touch torlist.log
touch working.csv

# start our log of activities
echo "script started at $(date)" >> torlist.log
echo "-------" >> torlist.log
echo "Working on our TOR node list" >> torlist.log
echo "-------" >> torlist.log
echo "-------" >> torlist.log

# Let's get all of the files we are going to work on first.
# we have to do different sets of tasks on each file, as they format things differently.
echo "Getting our first list" >> torlist.log
echo "https://www.dan.me.uk/torlist/" >> torlist.log
wget --no-check-certificate  "https://www.dan.me.uk/torlist/" -O ukdan.list
echo "-------" >> torlist.log
echo "getting our second list" >> torlist.log
echo "http://torstatus.blutmagie.de/ip_list_all.php/Tor_ip_list_ALL.csv" >> torlist.log
wget "http://torstatus.blutmagie.de/ip_list_all.php/Tor_ip_list_ALL.csv" -O german.list
echo "-------" >> torlist.log
echo "getting our third list" >> torlist.log
echo "https://check.torproject.org/exit-addresses" >> torlist.log
wget --no-check-certificate "https://check.torproject.org/exit-addresses" -O torsite.list
echo "-------" >> torlist.log
echo "getting our fourth list" >> torlist.log
echo "http://en.wikipedia.org/wiki/Category:Blocked_Tor_exit_nodes" >> torlist.log
wget "http://en.wikipedia.org/wiki/Category:Blocked_Tor_exit_nodes" -O wikipedia.list
echo "-------" >> torlist.log
echo "getting our fifth list" >> torlist.log
echo "http://www.enn.lu/status/" >> torlist.log
wget "http://www.enn.lu/status/" -O ennlu.list
echo "-------" >> torlist.log
echo "getting the seventh list now" >> torlist.log
echo "https://gitweb.torproject.org/tor.git/blob/HEAD:/src/or/config.c#l819" >> torlist.log
wget --no-check-certificate "https://gitweb.torproject.org/tor.git/blob/HEAD:/src/or/config.c#l819" -O gist.list
echo "-------" >> torlist.log
echo "getting list number eight now" >> torlist.log
echo "http://rules.emergingthreats.net/blockrules/emerging-tor.rules" >> torlist.log
wget http://rules.emergingthreats.net/blockrules/emerging-tor.rules -O ethreats.list
echo "-------" >> torlist.log
echo "getting the ninth list now"
echo "http://hqpeak.com/torexitlist/free/?format=json" >> torlist.log
wget http://hqpeak.com/torexitlist/free/?format=json -O hqpeak.list
echo "-------" >> torlist.log



# some quick formatting
echo "-----------------" >> torlist.log
echo "-----------------" >> torlist.log

# Batch 1: UKdan and German site
# Let's start working with, manipulating our files.
# These files are only a listing of IP addresses, so we do not need to do anything more at this time, 
# with these files.
cat ukdan.list >> working.csv
wc -l working.csv >> torlist.log
echo "-------" >> torlist.log
cat german.list >> working.csv
wc -l working.csv >> torlist.log
echo "-------" >> torlist.log


# Batch 2: Tor, wikipedia, ennlu, Github, ethreats, hqpeak
# This grouping of files, requires a bit more processing as the information downloaded, is not in a 
# CSV file format, or contains other information that just an IP list. This next set of commands will
# create an array of these lists, and do the processing we need to strip all non essential data out
# of the files. We will use a FOR loop to go throgh our array.
torbatch2=('torsite.list' 'wikipedia.list' 'ennlu.list' 'gist.list' 'ethreats.list' 'hqpeak.list')
echo "-----------------" >> torlist.log
echo "-----------------" >> torlist.log
for list in "${torbatch2[@]}"
do :
	echo "$list" >> torlist.log
	grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' $list >> working.csv
	wc -l working.csv >> torlist.log
	echo "-----" >> torlist.log
done
echo "-----------------" >> torlist.log
echo "-----------------" >> torlist.log


# Our final set of processing is to go through our working list, and pull out any addresses, that are RFC 3330.
# I am not grabbing all of those addresses. I am only grabbing a small portion of them, and making sure our list
# is not corrupted by that.
grep -E -v '(^127\.0\.0\.1)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)|(^0.)|(^169\.254\.)' working.csv >> validated.csv
wc -l validated.csv >> torlist.log
echo "-----------------" >> torlist.log
echo "-----------------" >> torlist.log


# We need to start sorting our list and removing any duplicates
echo "Now, I am going to sort our list that we have been working on" >> torlist.log
sort validated.csv >> sorted.csv
echo "-------" >> torlist.log
echo "Now, we will remove any duplicates in the list, using uniq." >> torlist.log
echo "before removing duplicates.:" >> torlist.log
wc -l sorted.csv >> torlist.log
echo "-------" >> torlist.log
uniq sorted.csv >> clean.csv
echo "After pulling out duplicates:" >> torlist.log
wc -l clean.csv >> torlist.log
echo "-----------------" >> torlist.log
echo "-----------------" >> torlist.log


# Now, we need to grab all of our files, and zip them up for long term storage.
# I am using zip, since that is more common on windows systems.
zip csv-files.zip *.csv
mv clean.csv ../
rm -rf *.csv
zip list-files.zip *.list
rm -rf *.list
cp torlist.log ../
# this will create our final zip file, and will date stamp the file.
# this will help us go back and find when an IP was added to our lists.
zip tornodes-$(date +%F).zip csv-files.zip list-files.zip torlist.log
cp tornodes-$(date +%F).zip ../
rm -rf csv-files.zip
rm -rf list-files.zip
rm -rf torlist.log
cd ../
mv torlist.log tornodes-$(date +%F).log
mv clean.csv tornodes-$(date +%F).csv
rm -rf tornodes 
# EOS


# This copyright notice is included for using the emerging threats rule.
#*************************************************************
#
#  Copyright (c) 2003-2013, Emerging Threats
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
#  following conditions are met:
#  
#  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
#    disclaimer.
#  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
#    following disclaimer in the documentation and/or other materials provided with the distribution.
#  * Neither the name of the nor the names of its contributors may be used to endorse or promote products derived 
#    from this software without specific prior written permission.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED WARRANTIES, 
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
#  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
#  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
#
#

# EOF
