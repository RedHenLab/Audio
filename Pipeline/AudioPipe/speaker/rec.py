import os, sys, commands

def dia2spk(audio, dest, model, seg, meta, ext):
    current_module = sys.modules[__name__]
    file_path = os.path.join(os.path.dirname(os.path.abspath(current_module.__file__)), "SpeakerID.py")
    print commands.getstatusoutput("python "+file_path+" "+model+" "+audio+" "+seg+" "+meta+" "+dest+" "+ext)
    return os.path.join(dest,os.path.basename(audio).split('.')[0]+ext)

def getspk(audio, dest, model, meta, ext):
    current_module = sys.modules[__name__]
    file_path = os.path.join(os.path.dirname(os.path.abspath(current_module.__file__)), "SpeakerRec.py")
    print commands.getstatusoutput("python "+file_path+" "+model+" "+audio+" "+meta+" "+dest+" "+ext)
    return os.path.join(dest,os.path.basename(audio).split('.')[0]+ext)

