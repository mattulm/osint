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

###############################################
# First let's grab some files from this site.
mkdir -p /tmp/osint/hashes; cd /tmp/osint/hashes;
wget --header="$HEADER" --user-agent="$UA21" http://www.virusign.com/home.php?d=4&r=300&c=hashes&o=date&s=DESC&p=1
sleep 5; 
mv /tmp/osint/hashes/home.* /tmp/osint/hashes/hashes_virusign_detect4_source_$TODAY.txt;
wget --header="$HEADER" --user-agent="$US22" http://www.virusign.com/home.php?d=3&r=300&c=hashes&o=date&s=DESC&p=1
sleep 5;
mv /tmp/osint/hashes/home.* /tmp/osint/hashes/hashes_virusign_detect3_source_$TODAY.txt;
wget --header="$HEADER" --user-agent="$US22" http://www.virusign.com/home.php?d=2&r=300&c=hashes&o=date&s=DESC&p=1 
sleep 5;
mv /tmp/osint/hashes/home.* /tmp/osint/hashes/hashes_virusign_detect2_source_$TODAY.txt
wget --header="$HEADER" --user-agent="$US22" http://www.virusign.com/home.php?d=1&r=300&c=hashes&o=date&s=DESC&p=1 
sleep 5;
mv /tmp/osint/hashes/home.* /tmp/osint/hashes/hashes_virusign_detect1_source_$TODAY.txt



##################################################
# OK, now let's clean up the files a little, and 
# pull only our hashes out of the files.
cd /tmp/osint/hashes;
# SHA 256 hashes
cat hashes_virusign_detect4_source_$TODAY.txt | grep -a -o -e "[0-9a-f]\{64\}" >> /tmp/osint/hashes/virusign_sha256_source_$TODAY.txt
cat hashes_virusign_detect3_source_$TODAY.txt | grep -a -o -e "[0-9a-f]\{64\}" >> /tmp/osint/hashes/virusign_sha256_source_$TODAY.txt
cat hashes_virusign_detect2_source_$TODAY.txt | grep -a -o -e "[0-9a-f]\{64\}" >> /tmp/osint/hashes/virusign_sha256_source_$TODAY.txt
cat hashes_virusign_detect1_source_$TODAY.txt | grep -a -o -e "[0-9a-f]\{64\}" >> /tmp/osint/hashes/virusign_sha256_source_$TODAY.txt


##########################################################
### Let's look at the prepared files from this site now.
wget --header="$HEADER" --user-agent="$US22" http://www.virusign.com/todays_hashlist.php -O /tmp/osint/hashes/hashlist_virusign_$TODAY.txt
wget --header="$HEADER" --user-agent="$US21" http://www.virusign.com/hashlists/2014-06-22.csv -O /tmp/osint/hashlist_virusign_yesterday_$TODAY.txt




######################################################
### Let's pull some hashes from these two files now.
# SHA256 Hashes
awk -F "\"*,\"*" '{print $2}' /tmp/osint/hashes/hashlist_virusign_$TODAY.txt >> /tmp/osint/hashes/sha256_virusign_master.txt
awk -F "\"*,\"*" '{print $2}' /tmp/osint/hashlist_virusign_yesterday_$TODAY.txt >> /tmp/osint/hashes/sha256_virusign_master.txt
# SHA1 Hashes
awk -F "\"*,\"*" '{print $3}' /tmp/osint/hashes/hashlist_virusign_$TODAY.txt >> /tmp/osint/hashes/sha1_virusign_master.txt
awk -F "\"*,\"*" '{print $3}' /tmp/osint/hashlist_virusign_yesterday_$TODAY.txt >> /tmp/osint/hashes/sha1_virusign_master.txt
# MD5 Hashes
awk -F "\"*,\"*" '{print $4}' /tmp/osint/hashes/hashlist_virusign_$TODAY.txt >> /tmp/osint/hashes/md5_virusign_master.txt
awk -F "\"*,\"*" '{print $4}' /tmp/osint/hashlist_virusign_yesterday_$TODAY.txt >> /tmp/osint/hashes/md5_virusign_master.txt



#
# EOF
