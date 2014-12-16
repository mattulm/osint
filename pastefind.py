#!/usr/bin/python
# Python file to monitor pastebin for pastes containing the passed regex

import sys
import time
import urllib
import re

# User-defined variables
time_between = 7       	#Seconds between iterations (not including time used to fetch pages - 
						#setting below 5s may cause a pastebin IP block, too high may miss pastes)
						
error_on_cl_args = "Please provide a single regex search via the command line"   
						#Error to display if improper command line arguments are provided

# Check for command line argument (a single regex)
if len(sys.argv) != 1:
    search_term = sys.argv[1]
else:
    print error_on_cl_args
    exit()

iterater = 1

while(1):
    counter = 0

    print "Scanning pastebin - iteration " + str(iterater) + "..."
    
    #Open the recently posted pastes page
    try:
        url = urllib.urlopen("http://pastebin.com/archive")
        html = url.read()
        url.close()
        html_lines = html.split('\n')
        for line in html_lines:
            if counter < 10:
                if re.search(r'<td><img src=\"/i/t.gif\"  class=\"i_p0\" alt=\"\" border=\"0\" /><a href=\"/[0-9a-zA-Z]{8}">.*</a></td>', line):
                    link_id = line[72:80]
                    #print link_id
                    
                    #Begin loading of raw paste text
                    url_2 = urllib.urlopen("http://pastebin.com/raw.php?i=" + link_id)
                    raw_text = url_2.read()
                    url_2.close()
                    
                    #if search_term in raw_text:
                    if re.search(r''+search_term, raw_text):
                        print "FOUND " + search_term + " in http://pastebin.com/raw.php?i=" + link_id
                    
                    counter += 1
    except(IOError):
        print "Network error - are you connected?"
    except:
        print "Fatal error! Exiting."
        exit()
    iterater += 1
    time.sleep(time_between)