#!/usr/bin/python
# This python script is used to extract only audio in .wav format from a video file

import sys,os
from subprocess import call

def video_to_audio(input_folder, out_folder):
    os.chdir(input_folder)
    files = os.listdir('.')
    for file in files:
         if file.endswith('.mp4'):
              wav_44k = file.split('.')[0] + '_44k.wav'
              wavname = file.split('.')[0] + '.wav'
              call(['ffmpeg', '-i', file , wav_44k] )
              call([ 'sox' , wav_44k, '-c' , '1' , '-r', '8000', wavname ])
              call(['mv',wavname, out_folder])      
              print ' Extracted audio for ' +  file


def main():
    
    if len(sys.argv) < 3:
         print ' Usage: python 001_audio_from_video_extractor.py data_folder destination_folder '
         exit
    input_folder = sys.argv[1]
    out_folder = sys.argv[2]
    video_to_audio(input_folder, out_folder)


if __name__ == '__main__':
    main()
