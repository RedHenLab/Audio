#!/usr/bin/python
import recognition as SR
from AudioPipe.features import mfcc
from silence import remove_silence
import scipy.io.wavfile as wav
from time import localtime, strftime
import sys, getopt, os
import datetime

def readSegFile(segfn):
    inFile = open(segfn)
    fileText = inFile.read()
    rows = fileText.split('\n')
    segments = []
    for row in rows:
        cols = row.split(' ')
        segments.append(cols)
    return segments

def myLengend(speakermodel,primary):
    lengend = primary+'|'+ strftime("%Y-%m-%d %H:%M", localtime()) + '|Source_Program=SpeakerID.py ' + \
    speakermodel + '|Source_Person=He Xu\n'
    return lengend

def totime(secs):
    m, s = divmod(secs, 60)
    h, m = divmod(m, 60)
    return h, m, s

def readHeader(infofn):    
    inFile = open(infofn)
    fileText = inFile.read()
    lines = fileText.split('\n')
    header = ''
    TOP = None
    for line in lines:
        header = header + line + '\n'
        if line.startswith('TOP') and TOP is None:
            segs = line.split('|')
            TOP = segs[1]
        if line.startswith('LBT'):
            break
    endline = lines[-2]
    return header, endline, TOP

def readSegFeat(start_t, end_t, signal, sr):
    try:
        sig = signal[int(sr * start_t) : int(sr * end_t)] 
    except:
        sig = signal[int(sr * start_t) : -1]
    cleansig = remove_silence(sr, sig)
    mfcc_vecs = mfcc(cleansig, sr, numcep = 15) 
    return mfcc_vecs

def main(argv):
    if len(argv) != 6:
        print 'usage: SpeakerID.py <trained_model> <wav_file> <segmentation_file> <metainfo_file> <dest_dir> <ext>'
        sys.exit(2)
        
    speakermodel = argv[0]
    audiofn = argv[1]
    segfn = argv[2]
    infofn = argv[3]
    dest = argv[4]
    ext = argv[5]
    if "gen" in ext:
        classnm = "Gender="
    else:
        classnm = "Name="
        
    primary_tag = ext[1:].upper()+"_01"


    segments = readSegFile(segfn)
    fn = infofn.split('.')[0].split('/')[-1]
    outFile = open(os.path.join(dest,fn+ext), 'w')
    (header, endline, TOP) = readHeader(infofn)
    outFile.write(header)
    TOP_year = int(TOP[:4])
    TOP_month = int(TOP[4:6])
    TOP_day = int(TOP[6:8])
    TOP_hour = int(TOP[8:10])
    TOP_min = int(TOP[10:12])
    TOP_sec = int(TOP[12:14])
    t = datetime.time(TOP_hour, TOP_min, TOP_sec)
    d = datetime.date(TOP_year, TOP_month, TOP_day)
    dt = datetime.datetime.combine(d, t)
    
    outFile.write(myLengend(speakermodel,primary_tag))
    speakerRec = SR.GMMRec.load(speakermodel)
    (sr, signal) = wav.read(audiofn)
    if len(signal.shape) > 1:
            signal = signal[:, 0]  
    tformat = "%02Y%02m%02d%02H%02M%02S"
    for i in xrange(len(segments)-1):   
        start_time = float(segments[i][3])
        try:
            end_time = float(segments[i+1][3])
        except:
            end_time = start_time + float(segments[i][-5])
        try:
            segfeat = readSegFeat(start_time, end_time, signal, sr)
        except:
            print (start_time, end_time)
        (speaker, llhd) = speakerRec.predict(segfeat)
        strdt_start = dt+datetime.timedelta(seconds=start_time)
        timestr_start = "%s.%03d|" % (strdt_start.strftime(tformat),strdt_start.microsecond/1000)
        strdt_end = dt+datetime.timedelta(seconds=end_time)
        timestr_end = "%s.%03d|" % (strdt_end.strftime(tformat),strdt_end.microsecond/1000)
        entry = timestr_start + \
        timestr_end + primary_tag+'|'+classnm + speaker + "|Log Likelihood=" + str(llhd) + "\n"
        outFile.write(entry)
    outFile.write(endline)
    outFile.close()
    
if __name__ == "__main__":
    main(sys.argv[1:])