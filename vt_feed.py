#!/usr/bin/env python
'''
VirusTotal Feed Collector
Set your API and change max limit as required
'''

__description__ = 'VT Feed Collector'
__author__ = 'Kevin Breen http://techanarchy.net'
__version__ = '0.3'
__date__ = '2013/10'

import sys
import os
import urllib2
from optparse import OptionParser
import xml.etree.cElementTree as ET

#####################################  USER CONFIG HERE    ########################################################
api_key = '4f2a278c757ca832566afd2b07b599584a0d391e36d862884bc8458512794e55'
feed_url = 'https://www.virustotal.com/intelligence/hunting/notifications-feed/?key=%s&output=xml' % api_key
max_down = 20
###################################################################################################################

# Set Global Vars
counter = 0
exists = 0
downloads = 0

def main():
	parser = OptionParser(usage='usage: %prog [options] ruleName\n' + __description__, version='%prog ' + __version__)
	parser.add_option("-s", "--RuleSet", action='store_true', default=False, help="Specify a Single RuleSet")
	parser.add_option("-n", "--RuleName", action='store_true', default=False, help="Specify a Single RuleName")
	parser.add_option("-l", "--list", action='store_true', default=False, help="List And Coutn All Matches")
	(options, args) = parser.parse_args()
	if (options.RuleSet == True or options.RuleName == True) and len(args) != 1:
		parser.print_help()
		sys.exit()

	#Pull the XML Feed from VT Int
	request = urllib2.Request(feed_url, headers={"Accept" : "application/xml"})
	xml = urllib2.urlopen(request)
	#Parse the XML 
	tree = ET.parse(xml)
	root = tree.getroot()


	if options.list == True: # Just list the output of the feed
		list(root)
		sys.exit()
	#Im only interested in rule names and the sha to download
	for item in root[0].findall('item'):
		try:
			sha256, ruleset, rulename = item.find('title').text.split()
		except:
			print "Could Not Find Valid Title Line, Does your RuleSet, RuleName contain Spaces?"
			sys.exit()
		if options.RuleSet == True:
			if args[0] == ruleset:
				download(sha256, ruleset, rulename)
		elif options.RuleName == True:
			if args[0] == rulename:
				download(sha256, ruleset, rulename)
		else:
			download(sha256, ruleset, rulename)

	print "\nTotal Hashes in Feed", counter
	print "Files Skipped", exists
	print "Files downloaded", downloads		

# This is the donwnloads function
def download(sha256, ruleset, rulename):
	global exists, downloads, max_down, counter
	# create the folder paths
	if not os.path.exists(os.path.join(ruleset, rulename)):
		os.makedirs(os.path.join(ruleset, rulename))
	# if the file already exists dont download again
	if os.path.exists(os.path.join(ruleset, rulename, sha256)):
		print "Hash Already Exists, Passing"
		exists +=1
	#Stay below the max_down count and download
	elif downloads < max_down:
		url = "https://www.virustotal.com/intelligence/download/?hash=%s&apikey=%s" %(sha256, api_key)	
		print "downloading %s" % sha256
		f = urllib2.urlopen(url)
		data = f.read()

		# Save each file in to a folder after the rule
		with open(os.path.join(ruleset, rulename, sha256), "wb") as save_file:
			save_file.write(data)
		downloads +=1
	elif downloads > max_down:
		print "Self Imposed Download Limit Reached"
	counter +=1

# List all the samples in the feed that dont exist in the sample folders
def list(root):
	counts = {}
	for item in root[0].findall('item'):
		try:
			sha256, ruleset, rulename = item.find('title').text.split()
			if rulename in counts and (not os.path.exists(os.path.join(ruleset, rulename, sha256))): # if rule is in feed and doesnt exist increment the counter
				counts[rulename] +=1
			elif not os.path.exists(os.path.join(ruleset, rulename, sha256)): # If theres no entry in the counter yet set one.
				counts[rulename] = 1
		except:
			print "Could Not Find Valid Title Line, Does your RuleSet, RuleName contain Spaces?"
			sys.exit()
	if len(counts) > 0:
		print "New Items in feed not already saved" # Print the results of the counts
		for rule, count in counts.items():
			print rule,count
	else:
		print "No New Match's For Download"

if __name__ == "__main__":
	if api_key == 'Your Key Here':
		print "You need to add your own API key"
		sys.exit()
	main()
