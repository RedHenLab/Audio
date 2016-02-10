import subprocess, sys, re

AUDIO_PATH = "audio-resources-temp/"

def usage():
    print "DESCRIPTION:"
    print "CLIP-FIND: tool to create and query an audio fingerprint database"
    print ""
    print "USAGE:"
    print "python clip-find.py [-options] [argument]"
    print ""
    print "OPTIONS:"
    print " * -train:       trains the Panako library with the audio taken from the sweep catalogue."
    print "                 the argument must be a string representing a date in the US format mm-dd-yyyy."
    print "                 all the available data for that day in the Newscape database will be used to train"
    print "                 the Panako library."
    print " * -fetch:       fetches audio from the /sweep/ folder and creates an audio-resources-temp folder,"
    print "                 then 15 seconds clips are made from the audio and put into the audio-resources-temp/overlap-clips/"
    print "                 folder. the argument must be a string representing a date in the US format mm-dd-yyyy."
    print "                 this option is useful if your SSH connection is not very stable and the -train"
    print "                 option takes too long to complete. using -fetch and -fingerprint in two separate commands"
    print "                 equals using a single command with the -train option."
    print "                 only use -fetch if you are going to use -fingerprint."
    print " * -fingerprint: uses the Panako library to store audio fingerprints taken frome audio-resources-temp/overlap-clips/"
    print "                 using -fetch and -fingerprint in two separate commands equals using a single command with the"
    print "                 -train option. only use -fingerprint if you used -fetch already."

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
        elif option == "-fetch":
            fetch()
        elif option == "-fingerprint":
            fingerprint()
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
    checkPathIntegrity(video_path)
    subprocess.call(['scripts/extract_audio.sh', video_path, AUDIO_PATH])
    subprocess.call(['touch', AUDIO_PATH+'/overlap-clips/clips.txt'])
    f = open(AUDIO_PATH+"/overlap-clips/clips.txt", "w")
    findresults = subprocess.call(['find', AUDIO_PATH+'/overlap-clips/', '-name', '*.m4a'], stdout=f)
    subprocess.call(["java", "-jar", "panako/panako-1.3-clipfind.jar", "store", AUDIO_PATH+"/overlap-clips/clips.txt"])
#   subprocess.call(["rm", "-r", AUDIO_PATH])

def fetch():
    date = sys.argv[2]
    dateList = re.split("-", date)
    video_path = "/sweep/"+dateList[0]+"/"+dateList[0]+"-"+dateList[1]+"/"+dateList[0]+"-"+dateList[1]+"-"+dateList[2]+"/"
    checkPathIntegrity(video_path)
    subprocess.call(['scripts/extract_audio.sh', video_path, AUDIO_PATH])

def fingerprint():
    try:
		ls_result = subprocess.check_output(['ls', AUDIO_PATH+"/overlap-clips/"], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
		ls_result = e.output
    if "No such file" in ls_result:
    	print "no "+AUDIO_PATH+"/overlap-clips folder found. you have to -fetch before you -fingerprint!"
        print "if you want to do everything (clip creation + fingerprinting) in one go, please use -train."
        print ""
        usage()
    	sys.exit(0)
    subprocess.call(['touch', AUDIO_PATH+'/overlap-clips/clips.txt'])
    f = open(AUDIO_PATH+"/overlap-clips/clips.txt", "w")
    findresults = subprocess.call(['find', AUDIO_PATH+'/overlap-clips/', '-name', '*.m4a'], stdout=f)
    subprocess.call(["java", "-jar", "panako/panako-1.3-clipfind.jar", "store", AUDIO_PATH+"/overlap-clips/clips.txt"])
#   subprocess.call(["rm", "-r", AUDIO_PATH])

def main():
    parse()

main()
