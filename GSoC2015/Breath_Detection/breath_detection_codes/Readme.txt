############################################################

In this Readme, the procedure to run the codes is explained.

This folder contains matlab codes to extract detect breath segments in the given audio file.

##########################################################################################

1) Call_Detect_breath_video.sh: Execute this shell script, if the input is in video format and we have to detect the breath segments.
   To execute this code: sh Call_Detect_breath_video.sh /path/to/videofiles /path/where/audiofiles/to/be/saved
   Note: The output of the breath detections will also be saved in the same folder, where audio files are saved.

##########################################################################################

2) Call_Detect_breath_audio.sh: Execute this shell script, if audio files are available and breath detection need to be done.
   To execute this code: Call_Detect_breath_audio.sh /path/to/audiofiles/ /path/where/breathDetectionOutput/to/be/saved

##########################################################################################

Following are matlab codes which are called from the script files

1) Audio_from_video.py: This is a python code to extract audio from the given video file.

2) Detect_breath.m: This code calls all other codes and also writes the detected breath regions to a text (.txt) file.

3) epochExtract.m and epochStrengthExtract_voc.m: These codes are used to extract the excitation source features required for
detection of breath segments.

4) RunMean.m: This code is used to smooth the feature contours obtained

5) vnvseg_voc.m: This code is used to select possible regions of breath in the audio signal by thresholding the excitation source features.

6) zff_method.m and zffsig.m which are used for the feature extraction.
