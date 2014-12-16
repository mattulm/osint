#!/usr/bin/env python2
# -*- coding: utf-8 -*-

####
# Author: Edvard Holst
# Version: 1.0
###
import sys

def gendomaincontent(domain):
    domain_items = domain.split(".")
    content = ""
    for i in domain_items:
        content += "|%02d|%s" %(len(i),i)
    content += "|00|"
    print content


args = iter(sys.argv)
next(args)
for arg in args:
    gendomaincontent(arg)
