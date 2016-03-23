import subprocess
import commands, os

def Commandline(arglist, cwd_path = None):
    p = subprocess.Popen(arglist,
                         stdout = subprocess.PIPE, stderr = subprocess.PIPE, cwd = cwd_path)
    output, err = p.communicate()
    exitcode = p.returncode
    return output, err, exitcode

def video2audio(video, audio_dir, ext):
    audio = os.path.join(audio_dir,video.split("/")[-1].split(".")[0]+ext)
    commands.getstatusoutput("ffmpeg -i "+video+" -vn -f wav -ab 16k "+audio)
    return audio