#!/usr/bin/python
# This script extracts the audio from the video files
# This uses subprocess to call ffmpeg


import sys,os
from subprocess import check_call
import shutil



def audio_extractor(video_folder, audio_folder):
    os.chdir(video_folder)
    files = os.listdir('.')
    for file in files:
         if file.endswith('.mp4'):
              wave_file = file.split('.')[0] + '.wav'
              wave_downsampled = file.split('.')[0] + '_downsampled.wav'
              check_call([ 'ffmpeg', '-i', file , wave_file ])
              check_call([ 'sox' , wave_file, '-c' , '1' , '-r', '16000', wave_downsampled ])
              shutil.move(wave_downsampled, audio_folder)      
              print ' Done extracting audio for ' +  file


def main():
    
    if len(sys.argv) < 3:
         print ' Usage: python 001_audio_from_video_extractor.py data_folder destination_folder '
         exit
    video_folder = sys.argv[1]
    audio_folder = sys.argv[2]
    audio_extractor(video_folder, audio_folder)


if __name__ == '__main__':
    main()
