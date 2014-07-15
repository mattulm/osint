#!/bin/bash
# update-malwebnodes.sh
# Matthew Ulm
# 2014-03-05
#
#
# DISCLAIMER #1:
#
# This script is not intended for commercial use.
# this script is to help organizations monitor, combat, find, eradicate, etc. malware
# from their internal networks. The genesis for this list is just too many years
# being behind the eight ball as a system admin, and tired of re-imaging user machines.
# if we can detect it faster/ better/ stronger, we can hopefully tilt the scales back in 
# our favor.
#
#
# DISCLAIMER #2:
# The commercial or unauthorized use of any material within this script may violate copyright, trademark, and other laws. 
# From the sites the information is gathered from. THis script, adn teh data it collects must only be for non-commercial  
# use, and is intended to help system and network administrators protect the networks that they maintain only. This script can
# also be used for non-commercial home user. Any violation of this or any commercial use, the user of the script is instructed to
# immediately destroy any downloaded or printed materials.
#
#

# This script will gather a listing of different IP addresses from the malicious web
# and gather them all together in one listing, so that it can be uploaded into a SIEM,
# IDS< or other network level monitoring device.
# Commands used:
# touch, echo, wget, cat, wc, grep, sort, uniq, zip, cp, mv, date
# Let's get started
# First create some files
mkdir malweb
cd malweb
touch working.csv
touch malwebnodes.log
echo "We are starting our collection at: $(date)" >> malwebnodes.log
echo "-----" >> malwebnodes.log
echo "-----" >> malwebnodes.log


# Let's getting the listings from our sites. we will gather all of these files for
# processing further down in the script. If you add more sources to this script, just make sure that
# the name of the list ends in ".list". This naming convention is required for later parts of the script
# to process properly, and grab the information that we need for our data.
echo "Getting our first list from the Malware Domains site" >> malwebnodes.log
echo "http://www.malwaredomainlist.com/mdl.php?search=&colsearch=IP&quantity=All" >> malwebnodes.log
wget "http://www.malwaredomainlist.com/mdl.php?search=&colsearch=IP&quantity=All" -O malwaredomains.list
echo "-----" >> malwebnodes.log
echo "Gathering from Emerging Threats" >>
echo "http://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt" >> malwebnodes.log
wget "http://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt" -O emergingthreats.list
echo "-----" >> malwebnodes.log
echo "Gathering our list from the CI badguy list" >> malwebnodes.log
echo "http://www.ciarmy.com/list/ci-badguys.txt" >> malwebnodes.log
wget "http://www.ciarmy.com/list/ci-badguys.txt" -O ci.list
echo "-----" >> malwebnodes.log
echo "Grabbing a list from siri-urz." >> malwebnodes.log
echo "http://vxvault.siri-urz.net/URL_List.php" >> malwebnodes.log
wget "http://vxvault.siri-urz.net/URL_List.php" -O siriurz.list
echo "http://vxvault.siri-urz.net/ViriList.php?s=40&m=500" >> malwebnodes.log
wget "http://vxvault.siri-urz.net/ViriList.php?s=40&m=500" >> -O siriurz2.list
echo "-----" >> malwebnodes.log
echo "Grabbing a listing from the RSS feed at Malware Block List" >> malwebnodes.log
echo "http://www.malwareblacklist.com/mbl.xml" >> malwebnodes.log
wget http://www.malwareblacklist.com/mbl.xml -O mblrss.list
echo "-----" >> malwebnodes.log
echo "Getting our next set of lists" >> malwebnodes.log
echo "http://malwaredb.malekal.com/" >> malwebnodes.log
#
# This will be a couple of pulls to gather information from the last few months
# This script will pause in between each pull, so we do not hit the server too hard
#
wget "http://malwaredb.malekal.com/" -O mdb0.list
/bin/sleep 15 >> malwebnodes.log
wget "http://malwaredb.malekal.com/index.php?page=1" -O mdb1.list
/bin/sleep 15 >> malwebnodes.log
wget "http://malwaredb.malekal.com/index.php?page=2" -O mdb2.list
/bin/sleep 15 >> malwebnodes.log
wget "http://malwaredb.malekal.com/index.php?page=3" -O mdb3.list
/bin/sleep 15 >> malwebnodes.log
wget "http://malwaredb.malekal.com/index.php?page=4" -O mdb4.list
/bin/sleep 15 >> malwebnodes.log
wget "http://malwaredb.malekal.com/index.php?page=5" -O mdb5.list
/bin/sleep 15 >> malwebnodes.log
wget "http://malwaredb.malekal.com/index.php?page=6" -O mdb6.list
echo "-----" >> malwebnodes.log
echo "Getting the list from CyberCrime Tracker" >> malwebnodes.log
echo "http://cybercrime-tracker.net/all.php" >> malwebnodes.log
wget "http://cybercrime-tracker.net/all.php" -O crimetracker.list
echo "-----" >> malwebnodes.log
echo "A malware site listing form Poland" >> malwebnodes.log
echo "http://www.malware.pl/index.malware" >> malwebnodes.log
wget "http://www.malware.pl/index.malware" -O poland.list
echo "-----" >> malwebnodes.log
# you can register on this site for a personal download link to access the complete database. 
# This link is paired to the user registration.
echo "Getting the list from Malware URL" >> malwebnodes.log
echo "http://www.malwareurl.com/" >> malwebnodes.log
wget "http://www.malwareurl.com/" -O malwareurl.list
echo "-----" >> malwebnodes.log
# we are going to grab another listing of sites, and what not,


# Now lets start gathering all of our lists and iterating through all of them using while, so we can
# only pull out the IP addresses from these files. Lets get the a list of the files first, create and array that
# is that long, and then populate the array with each list file. Once we have done that, let's validate the
# addresses, and make sure we do not add any RFC 3330 IP ranges to our working list.
ls *.list >> listoflists.txt
while read line
do
	echo "$line" >> malwebnodes.log
	grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' $line >> working.csv
	wc -l working.csv >> malwebnodes.log
	echo "-----" >> malwebnodes.log
done < listoflists.txt


# Lets start our cleaning and sorting process to finish out our script, and close
# this portion of our information gathering data collection.
echo "---------------" >> malwebnodes.log
echo "---------------" >> malwebnodes.log
echo "Sorting and de-duplicating now." >> malwebnodes.log
zip malwarelists.zip *.list
rm -rf *.list
sort working.csv >> sorted.csv
uniq sorted.csv >> malware.csv
cp malware.csv ../
zip malwarecsv.zip *.csv
mv malwebnodes.log ../
cd ../
zip malwaregather.zip malweb/*
mv malwarelists.zip malwarelists_$(date +%F).zip
mv malwarecsv.zip malwarecsv_$(date +%F).zip
mv malwebnodes.log malwarenodes_$(date +%F).log



# EOS
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
# EOF