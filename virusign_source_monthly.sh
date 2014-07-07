#!/bin/bash
#
#

###
# Description: Some information about the source
#
# Name: ViruSign
# Frequency: Daily
# Types: hashes (MD5, SHA1, SHA256)



# Some Variables
HOME="/tmp/osint"
HEADER="Accept: text/html"
UA21="Mozilla/5.0 Gecko/20100101 Firefox/21.0"
UA22="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13; ) Gecko/20101203"
TODAY=$(date +"%Y-%m-%d")
if [! -d "/tmp/ossint" ]; then
        mkdir -p /tmp/osint;
fi
cd /tmp/osint;

#######################################################
### First let's get last month's file so that we can
### pull out the hashes from it.
mkdir -p /tmp/osint/hashes;
wget --header="$HEADER" --user-agent="$UA22" http://www.virusign.com/hashlists/2014-05.csv -O /tmp/osint/hashes/lastmonth_virusign_hashlist_$TODAY.csv


######################################################
### Let's pull some hashes from these two files now.
# SHA256 Hashes
awk -F "\"*,\"*" '{print $2}' /tmp/osint/hashes/lastmonth_virusign_hashlist_$TODAY.csv >> /tmp/osint/hashes/sha256_virusign_monthly_master.txt
# SHA1 Hashes
awk -F "\"*,\"*" '{print $3}' /tmp/osint/hashes/lastmonth_virusign_hashlist_$TODAY.csv >> /tmp/osint/hashes/sha1_virusign_monthly_master.txt
# MD5 Hashes
awk -F "\"*,\"*" '{print $4}' /tmp/osint/hashes/lastmonth_virusign_hashlist_$TODAY.csv >> /tmp/osint/hashes/md5_virusign_monthly_master.txt


#
# EOF
