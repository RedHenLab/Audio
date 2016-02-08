import subprocess, sys

def usage():
	print "DESCRIPTION:"
	print "segmentator: recognize commercial segments in an audio stream"
	print ""
	print "USAGE:"
	print "python segmentator.py [-options] [audio-location]"
	print ""
	print "OPTIONS:"
	print "  * -train:   trains the Panako library with the commercials files in [audio-location]."
	print "              the commercial files will be found automatically using 'find', so they must"
	print "              match the '*Commercial*' search string. The detected commercial files will be"
	print "              stored in [audio-location]/commercials.txt."
	print "  * -segment: uses the fingerprint database to match clips coming from the file in [audio-location]."
	print "              the file will be first divided in clips with around 50% overlap, then the clips will be"
	print "              used to query the fingerprint database. the segmentation analysis results will be found in"
	print "              [audio-location]/broadcast-segmentation.log. fingerprint matches will be found in"
	print "              [audio-location]/fingerprint-detection.log."
	print "  * -help:    shows this help page."
	print ""
	print "ABOUT [audio-location]:"
	print "[audio-location] should be a folder that contains ONLY the full audio file you want to find commercial segments for"
	print "and all the commercial files, named as described above. when using -segment, a folder called overlap-clips will"
	print "be created in the folder, containing the clips that will be matched in the fingerprinting step. please DO NOT"
	print "create the folder yourself, and delete the folder outright if you want the clips to be generated again. DO NOT just"
	print "delete the files it contains. check this issue if the program outputs a blank segmentation file."
	print ""

def parse():
	if len(sys.argv) != 3:
		print "wrong number of arguments."
		print ""
		usage()
		sys.exit(0)
	else:
		option = sys.argv[1]
		if option == "-help":
			usage()
			sys.exit(0)
		elif option == "-segment":
			segment()
		elif option == "-train":
			train()
		else:
			print "unsupported option."
			print ""
			usage()
			sys.exit(0)

def segment():
	audioLocation = sys.argv[2]
	try:
		mkdir_result = subprocess.check_output(['mkdir', audioLocation+'/overlap-clips/'], stderr=subprocess.STDOUT)
	except subprocess.CalledProcessError as e:
		mkdir_result = e.output
	if "Not a directory" in mkdir_result:
		print "invalid audio_location."
		sys.exit(0)
	if "File exists" not in mkdir_result:
		print "generating clips..."
		subprocess.call(['scripts/separate.sh', audioLocation+'/*.mp3', audioLocation+'/overlap-clips', '15', '7'])
		print "...done."
		subprocess.call(['touch', audioLocation+'/overlap-clips/clips.txt'])
		f = open(audioLocation+"/overlap-clips/clips.txt", "w")
		findresults = subprocess.call(['find', audioLocation+'/overlap-clips/', '-name', '*.mp3'], stdout=f)
	else:
		print "folder overlap-clips/ already found in "+audioLocation+": using the contents as matching clips."
	subprocess.call(["java", "-jar", "panako/panako-1.3.jar", "query", audioLocation+"/overlap-clips/clips.txt"])
	subprocess.call(["mv", "fingerprint-detection.log", audioLocation])
	subprocess.call(["mv", "broadcast-segmentation.log", audioLocation])

def train():
	audioLocation = sys.argv[2]
	f = open(audioLocation+'/commercials.txt', 'w')
	subprocess.call(['find', audioLocation, '-iname', '*Commercial*.mp3'], stdout=f)
	subprocess.call(["java", "-jar", "panako/panako-1.3.jar", "store", audioLocation+"/commercials.txt"])

def main():
	parse()

main()
