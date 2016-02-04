#### PyCASP for NewsScape Corpus

######Dependencies:

1. PyCASP with CUDA 
http://multimedia.icsi.berkeley.edu/scalable-big-data-analysis/pycasp/

2. HTK toolkit 
http://htk.eng.cam.ac.uk/

3. FFMPEG

######Run :

1. Make a folder with all your ".mp4" files. Let's say it is "test"

2. python 01_pre-processing.py test/ test_out -- this will extract ".wav" files and arrange the data

3. python 02_mfcc_extractor.py test_out/ -- this will extract mffc features from ".wav" files
Make sure that you set the right path of "HCopy"

4. python 03_diarizer_cfg.py test_out/ -- this will make configuration files for each mfcc file
You can play with the diarization parameters by editing this file

5. qsub 04_Cluster.pbs -- make a sequential job to diarize each file

NOTE : Change : replace "test_cfg" according to the name you keep instead of "test" 
