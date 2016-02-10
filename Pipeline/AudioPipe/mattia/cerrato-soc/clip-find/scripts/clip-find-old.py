import subprocess, sys, re

AUDIO_PATH = "audio-resources-temp/"

def usage():
    print "DESCRIPTION:"
    print "CLIP-FIND: tool to create and query an audio fingerprint database"
    print ""
    print "USAGE:"
    print "python clip-find.py [-options] [-argument]"
    print ""
    print "OPTIONS:"
    print " * -train: trains the Panako library with the audio taken from the sweep catalogue."
    print "           the argument must be a string representing a date in the US format mm-dd-yyyy."
    print "           all the available data for that day in the Newscape database will be used to train"
    print "           the Panako library."
    print " * -find:  queries the fingerprint database for the audio contained in the argument."

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
        elif option == "-train":
            train()
        elif option == "-find":
            find()
        else:
            print "unknown option."
            print ""
            usage()
            sys.exit(0)

def checkPathIntegrity(path):
    try:
		ls_result = subprocess.check_output(['ls', path], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
		ls_result = e.output
    if "No such file" in ls_result:
		print "invalid date string. please check syntax. also, are you really on cartago?"
		sys.exit(0)

def train():
    date = sys.argv[2]
    dateList = re.split("-", date)
    video_path = "/sweep/"+dateList[0]+"/"+dateList[0]+"-"+dateList[1]+"/"+dateList[0]+"-"+dateList[1]+"-"+dateList[2]+"/"
#   checkPathIntegrity(path)
    subprocess.call(['scripts/extract_audio.sh', video_path, AUDIO_PATH])
    subprocess.call(['touch', AUDIO_PATH+'/overlap-clips/clips.txt'])
    f = open(AUDIO_PATH+"/overlap-clips/clips.txt", "w")
    findresults = subprocess.call(['find', AUDIO_PATH+'/overlap-clips/', '-name', '*.m4a'], stdout=f)
    subprocess.call(["java", "-jar", "panako/panako-1.3.jar", "store", AUDIO_PATH+"/overlap-clips/clips.txt"])
#    subprocess.call(["rm", "-r", AUDIO_PATH])

def main():
    parse()

main()
