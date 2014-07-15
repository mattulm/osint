#!/bin/bash
###
# Description: Some information about the source
#
# Name: ViruSign
# Frequency: Daily
# Types: hashes (MD5, SHA1, SHA256)
# Some Variables
HOME="/tmp/osint"
SOURCES="/tmp/osint/sources"
HEADER="Accept: text/html"
UA21="Mozilla/5.0 Gecko/20100101 Firefox/21.0"
UA22="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13; ) Gecko/20101203"
TODAY=$(date +"%Y-%m-%d")
YESTD=$(date -d "1 day ago" '+%Y-%m-%d')
if [ ! -d "/tmp/ossint/sources/virusign" ]; then
	mkdir -p /tmp/osint/sources/virusign;
fi
datadirs=( ipv4 domains hashes rules )
for i in "${datadirs[@]}"; do
	if [ ! -d "$HOME/$i" ]; then
		mkdir -p $HOME/$i
	fi
done
cd $SOURCES/virusign
###############################################
# First let's grab some files from this site.
mkdir -p /tmp/osint/hashes; cd /tmp/osint/hashes;
wget --header="$HEADER" --user-agent="$UA21" "http://www.virusign.com/home.php?d=4&r=300&c=hashes&o=date&s=DESC&p=1" -O "virusign_detect1_$TODAY.txt"
sleep 5; 
mv /tmp/osint/hashes/home.* /tmp/osint/hashes/hashes_virusign_detect4_source_$TODAY.txt;
wget --header="$HEADER" --user-agent="$US22" "http://www.virusign.com/home.php?d=3&r=300&c=hashes&o=date&s=DESC&p=2" -O "virusign_detect2_$TODAY.txt"
sleep 5;
mv /tmp/osint/hashes/home.* /tmp/osint/hashes/hashes_virusign_detect3_source_$TODAY.txt;
wget --header="$HEADER" --user-agent="$US22" "http://www.virusign.com/home.php?d=2&r=300&c=hashes&o=date&s=DESC&p=3" -O "virusign_detect3_$TODAY.txt"
sleep 5;
mv /tmp/osint/hashes/home.* /tmp/osint/hashes/hashes_virusign_detect2_source_$TODAY.txt
wget --header="$HEADER" --user-agent="$US22" "http://www.virusign.com/home.php?d=1&r=300&c=hashes&o=date&s=DESC&p=4" -O "virusign_detect4_$TODAY.txt"
sleep 5;
mv /tmp/osint/hashes/home.* /tmp/osint/hashes/hashes_virusign_detect1_source_$TODAY.txt



##################################################
# OK, now let's clean up the files a little, and 
# SHA 256 hashes
for f in virusign_*_$TODAY.txt; do
	cat $f | grep -a -o -e "[0-9a-f]\{64\}" >> virusign_sha256_working_$TODAY.txt
done
#
### Let's look at the prepared files from this site now.
wget --header="$HEADER" --user-agent="$US22" http://www.virusign.com/todays_hashlist.php -O "hashlist_virusign_$TODAY.txt"
wget --header="$HEADER" --user-agent="$UA22" http://www.virusign.com/hashlists/$YESTD.csv -O "hashlist_virusign_$YESTD.txt"
#
### Let's pull some hashes from these two files now.
for i in hashlist_virusign_*.txt; do
	cat $i | awk -F "\"*,\"*" '{print $2}' >> virusign_sha256_working_$TODAY.txt
	cat $i | awk -F "\"*,\"*" '{print $3}' >> virusign_sha1_working_$TODAY.txt
	cat $i | awk -F "\"*,\"*" '{print $4}' >> virusign_md5_working_$TODAY.txt
done

#
# Sort and clean now
cat virusign_sha256_working_$TODAY.txt | sort | uniq >> virusign_sha256_$TODAY.txt 
cat virusign_sha1_working_$TODAY.txt | sort | uniq >> virusign_sha1_$TODAY.txt
cat virusign_md5_working_$TODAY.txt | sort | uniq >> virusign_md5_$TODAY.txt



#
# EOF
