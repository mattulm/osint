#!/bin/bash
#
#
# This is the script to gather the daily feed of IPs from various
# sources on the internet. This script will include some formatting
# and pruning commands to only gather IPs.
#
########################################################

# Gather a few from arbor networks
wget http://atlas.arbor.net/cc/US -O arbor_US_$today.txt
wget http://atlas.arbor.net/cc/CN -O arbor_CN_$today.txt
wget http://atlas.arbor.net/cc/DE -O arbor_DE_$today.txt
wget http://atlas.arbor.net/cc/KR -O arbor_KR_$today.txt
wget http://atlas.arbor.net/cc/EU -O arbor_EU_$today.txt
wget http://atlas.arbor.net/cc/CA -O arbor_CA_$today.txt 
wget http://atlas.arbor.net/cc/GB -O arbor_GB_$today.txt 
wget http://atlas.arbor.net/cc/RU -O arbor_RU_$today.txt 
wget http://atlas.arbor.net/cc/ZA -O arbor_ZA_$today.txt 
wget http://atlas.arbor.net/cc/NL -O arbor_NL_$today.txt 
wget http://atlas.arbor.net/cc/ES -O arbor_ES_$today.txt 
wget http://atlas.arbor.net/cc/TW -O arbor_TW_$today.txt 
wget http://atlas.arbor.net/cc/UA -O arbor_UA_$today.txt 
wget http://atlas.arbor.net/cc/FR -O arbor_FR_$today.txt
wget http://atlas.arbor.net/cc/MY -O arbor_MY_$today.txt
wget http://atlas.arbor.net/cc/MX -O arbor_MX_$today.txt
wget http://atlas.arbor.net/cc/IN -O arbor_IN_$today.txt

# Malekal Forum
wget http://malwaredb.malekal.com/export.php?type=url -O malekal_url_$today.txt
wget http://malwaredb.malekal.com/ -O malekal_p1_$today.txt
wget http://malwaredb.malekal.com/index.php?page=2 -O malekal_p2_$today.txt
wget http://malwaredb.malekal.com/index.php?page=3 -O malekal_p3_$today.txt
wget http://malwaredb.malekal.com/index.php?page=4 -O malekal_p4_$today.txt
wget http://malwaredb.malekal.com/index.php?page=5 -O malekal_p5_$today.txt
wget http://malwaredb.malekal.com/index.php?page=6 -O malekal_p6_$today.txt
wget http://malwaredb.malekal.com/index.php?page=7 -O malekal_p7_$today.txt
wget http://malwaredb.malekal.com/index.php?page=8 -O malekal_p8_$today.txt
wget http://malwaredb.malekal.com/index.php?page=9 -O malekal_p9_$today.txt
wget http://malwaredb.malekal.com/index.php?page=10 -O malekal_p10_$today.txt
wget http://malwaredb.malekal.com/index.php?page=11 -O malekal_p11_$today.txt
wget http://malwaredb.malekal.com/index.php?page=12 -O malekal_p12_$today.txt
wget http://malwaredb.malekal.com/index.php?page=13 -O malekal_p13_$today.txt
wget http://malwaredb.malekal.com/index.php?page=14 -O malekal_p14_$today.txt
wget http://malwaredb.malekal.com/index.php?page=15 -O malekal_p15_$today.txt

# The Malware Group
wget http://www.malwaregroup.com/ipaddresses/malicious -O mgroup_malware_$today.txt
wget http://www.malwaregroup.com/domains/malicious -O mgroup_domains_$today.txt
wget http://www.malwaregroup.com/ -O mgroup_frontpage_$today.txt

# Malware URL
wget http://www.malwareurl.com/ -O malwareurl_$today.txt

# Cyber Crime Tracker
wget http://cybercrime-tracker.net/all.php -O cybercrime_all_$today.txt
wget http://cybercrime-tracker.net/index.php -O cybercrime_tracker_$today.txt

# Gather the daily feeds from Emerging Threats
wget http://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt -O emerge_block_$today.txt
wget http://rules.emergingthreats.net/blockrules/compromised-ips.txt -O emerge_compromised_$today.txt
wget http://rules.emergingthreats.net/blockrules/emerging-ciarmy.rules -O ciarmy_$today.txt
wget http://rules.emergingthreats.net/blockrules/emerging-dshield-BLOCK.rules -O dshield_$today.txt
wget http://rules.emergingthreats.net/open/suricata/rules/drop.rules -O emerge_drop_$today.txt
wget http://rules.emergingthreats.net/blockrules/emerging-botcc.excluded -O emerge_botex_$today.txt
wget http://rules.emergingthreats.net/blockrules/emerging-botcc.portgrouped.rules -O emerge_botport_$today.txt

# Stop Badware
wget https://www.stopbadware.org/top-50 -O stopbadware_$today

# Scumware
wget --header="Accept: text/html" --user-agent="Mozilla/5.0 Gecko/20100101 Firefox/21.0" http://www.scumware.org/ -O scumware_$today.txt

# Gather the feeds from the Honey Net Organization
wget http://www.projecthoneypot.org/list_of_ips.php?t=r -O honeypot_tr_$today.txt
wget http://www.projecthoneypot.org/list_of_ips.php?t=d -O honeypot_td_$today.txt
wget http://www.projecthoneypot.org/list_of_ips.php?by=16 -O honeypot_16_$today.txt
wget http://www.projecthoneypot.org/list_of_ips.php?by=4 -O honeypot_4_$today.txt
wget http://www.projecthoneypot.org/list_of_ips.php?t=w -O honeypot_tw_$today.txt

# Malc0de list
wget http://malc0de.com/bl/IP_Blacklist.txt -O malc0de_blacklist_$today.txt
wget http://malc0de.com/database/ -O malcode_db1_$today.txt
wget http://malc0de.com/database/?&page=2 -O malcode_db2_$today.txt
wget http://malc0de.com/database/?&page=3 -O malcode_db3_$today.txt
wget http://malc0de.com/database/?&page=4 -O malcode_db4_$today.txt
wget http://malc0de.com/database/?&page=5 -O malcode_db5_$today.txt

# Open Block List
wget http://www.openbl.org/lists/base_7days.txt -O obl_7_$today.txt
wget http://www.openbl.org/lists/base_90days.txt -O obl_90_$today.txt

# No Think dot ORG
wget http://www.nothink.org/blacklist/blacklist_malware_http.txt -O nothink_http_$today.txt
wget http://www.nothink.org/blacklist/blacklist_malware_irc.txt -O nothink_irc_$today.txt
wget http://www.nothink.org/blacklist/blacklist_malware_dns.txt -O nothink_dns_$today.txt
wget http://www.nothink.org/viruswatch.php -O nothink_viruswatch_$today.txt

# CinsScore
wget http://cinsscore.com/list/ci-badguys.txt -O cibadguys_$today

# VXVault
wget http://vxvault.siri-urz.net/ViriList.php?s=0&m=800 -O vxvault_virilist_$today.txt
wget http://vxvault.siri-urz.net/URL_List.php -O vxvault_url_$today.txt

# Malware Domain List
wget http://www.malwaredomainlist.com/hostslist/spyeye.xml -O mdl_spyeye_$today.txt
wget http://www.malwaredomainlist.com/hostslist/zeus.xml -O mdl_zeus_$today.txt
wget http://www.malwaredomainlist.com/mdl.php?inactive=&sort=Date&search=&colsearch=IP&ascordesc=DESC&quantity=500&page=0 -O mdl_search_$today.txt
wget http://www.malwaredomainlist.com/hostslist/ip.txt -O mdl_ip_$today.txt
wget http://www.malwaredomainlist.com/hostslist/yesterday.php -O mdl_yesterday_$today.txt

# MalwareBlacklist
wget http://www.malwareblacklist.com/showMDL.php -O mbl_showmdl_$today

# Virus BlockList Netherlands
wget http://virbl.bit.nl/download/virbl.dnsbl.bit.nl.txt -O virbl_$today.txt

# Malware.com.br
wget http://www.malware.com.br/cgi/submit?action=stats&s=domains -O malware_brazil_$today.txt

# Malware.pl
wget http://www.malware.pl/ -O malware_poland_$today.txt

# Clean-MX
wget http://support.clean-mx.de/clean-mx/viruses?response=alive -O cleanMX_virus_$today.txt

# No Think dot ORG
wget http://www.nothink.org/honeypots/malware_network_activity.xml -O nothink_malware_$today.txt
wget http://www.nothink.org/blacklist/blacklist_ssh_week.txt -O nothink_sshscan_$today.txt



### Loop through the different files collected 
### and strip out the IPv4 addresses from them.
################################################
# Honeypot
for f in *_$today.txt; do
	cat $f | grep -E -o '(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-5][0-9]|[01]?[0-9][0-9]?)' >> ip_master_$today.txt
done

### Now collect all of the IPs adn put them in
### one file that can be quickly imported into
### the SIEM
cat ip_master_$today.txt | sort | uniq >> ip_list_daily_$today.txt
# turn it into a CSV file
cat ip_list_daily_$today.txt | awk '{print $0","}' >> ip_list_daily.csv

#
# EOF
