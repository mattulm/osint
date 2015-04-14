import urllib2

urls = {'tor-exit' : 'https://check.torproject.org/exit-addresses' }


for key in urls:
	try:
		file = urllib2.urlopen(urls[key])
	except:
		print "Unable to download: ", key, "->", urls[key]
	data = file.readlines()
	output = open(key + "-indicators" + ".txt","w")

if key == "tor-exit" :
	for line in data:
		if not line.strip(): continue
		if line.startswith("ExitAddress"):
			line = line.strip()
			words = line.split()
			output.write(words[1] + "\n")
	print "Completed Processing the", key, "feed. Check the current directory"
output.close()
file.close()
