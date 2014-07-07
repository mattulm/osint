#!/bin/bash
#
# Spammers IPv4 list
#


# Emerging Threats
wget http://rules.emergingthreats.net/fwrules/emerging-IPF-DROP.rules
wget http://rules.emergingthreats.net/blockrules/emerging-drop-BLOCK.rules

# Project Honeynet
wget http://www.projecthoneypot.org/list_of_ips.php?t=p
wget http://www.projecthoneypot.org/list_of_ips.php?t=s

# Knujon
wget http://knujon.com/ips/
wget http://knujon.com/domains/

# Clean-MX
wget http://support.clean-mx.de/clean-mx/phishing.php
wget http://support.clean-mx.de/clean-mx/portals.php

# Cisco Sender Base
wget http://www.senderbase.org/static/spam/

# SORBS
wget http://dnsbl.sorbs.net/home/stats.shtml

# Stop Forum Spam
wget http://www.stopforumspam.com/
wget http://www.stopforumspam.com/downloads/listed_ip_90_all.zip

# UCEprotect
wget http://wget-mirrors.uceprotect.net/rbldnsd-all/dnsbl-1.uceprotect.net.gz
wget http://wget-mirrors.uceprotect.net/rbldnsd-all/dnsbl-2.uceprotect.net.gz
wget http://wget-mirrors.uceprotect.net/rbldnsd-all/ips.backscatterer.org.gz

# Phish Watch
# wget http://lists.clean-mx.com/pipermail/phishwatch/
# This one will take some time to figure out how to parse this.

# V4BL
wget http://v4bl.org/RTIPstatus.html

# Unsubscore
wget http://www.unsubscore.com/blacklist.txt


