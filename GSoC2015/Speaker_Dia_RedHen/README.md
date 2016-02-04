## Speaker Diarization Module : Heterogeneous news data

Detailed Documentation : http://web.iiit.ac.in/~karan.singla/redhenproposal.pdf

####Using ALIZE
Now user can also use ALIZE speaker identification system instead of LIUM 
just use ALIZE_spk_seg/spk_det.sh

####Using PyCASP
User can also use PyCASP based diarization system :
Check "pycasp" folder for instructions.

####Using LIUM

Below Modules are primarily for running LIUM diarization system :

####### Module 1
This will extract 16kz audio date from Mp4 files and divide them according to respective news network
Data-PreProcessing

Requirements :
     1. Python (ofcourse, wrapper is in python)
     2. FFMPEG (https://www.ffmpeg.org/download.html)

python 01_pre-processing.py |path-to-mp4-data| |output_name|

#######Module 2
This module takes input the data folder created in previous step and do produces diarization output for each audio with data organized similarly to audio folder with name <inp>_seg

python 02_single_show_diarization.py |path-to-audio-data|

#######Module 3
Cross-show diarization : Still under development

Note :
"Scripts" folder contains supporting/utility scripts for the pipeline.
Change the poitner to "lium.jar" in scripts/diarization.sh, if needed
