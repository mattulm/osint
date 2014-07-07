#!/bin/bash
#
# Spammer Domains



# Project Honeynet
wget http://www.projecthoneypot.org/comment_spammer_urls.php?dt=all
wget http://www.projecthoneypot.org/comment_spammer_urls.php?dt=30
wget http://www.projecthoneypot.org/comment_spammer_urls.php?dt=7

# Knujon
wget http://knujon.com/domains/

# Clean-MX
wget http://support.clean-mx.de/clean-mx/phishing.php
wget http://support.clean-mx.de/clean-mx/portals.php

# SORBS
wget http://dnsbl.sorbs.net/home/stats.shtml

# Abuse.org CBL data
wget http://cbl.abuseat.org/domain.html
wget http://cbl.abuseat.org/domaintraffic.html

# Phish Tank
wget http://www.phishtank.com/phish_search.php?valid=y&active=y&Search=Search

# V4BL
wget http://v4bl.org/RTIPstatus.html

# AntiSpam
wget http://antispam.imp.ch/swinog-uri-rbl.txt


