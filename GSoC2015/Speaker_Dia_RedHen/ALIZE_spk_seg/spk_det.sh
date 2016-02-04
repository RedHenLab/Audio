s scripts a mp4 file and does the diarization of it using GMM based method to do speaker diarization ###############


inp=$1 # input mp4 file

audio=".wav"
seg=".lbl"

showname1=`echo "$inp" | cut -d'.' -f1`
echo "$showname" > lst/list.txt
showname2 = "$showname$audio"

ffmpeg -i $inp -vn -f wav -ab 16k data/sph/$showname2  


#Parameter computation from sphere signal file using the SPRO toolkit (http://www.irisa.fr/metiss/guig/spro/)
#12LFCC+Energy+Delta+DeltaDelta for speech/non speech segmentation
#20LFCC+energy for segmentation and resegmentation steps

./scripts/feature_extract.sh lst/list.lst 39 prm_39LFCC

./scripts/feature_extract.sh lst/list.lst 21 prm_21LFCC

########
#Segmentation process in acoustic classes (speech, telephone, music+speech depending on the number of acoustic models and acoustic types (GMM models) given in the config file. Resulting files are in the lblAcousticSegmentationWithMusic directory
########

./bin/AcousticSegmentation --config cfg/AcousticSegmentation.cfg --listFileToSegment ./lst/list.lst > log/AcousticSegmentation.log

#######
# To launch the speaker diarization steps, you need to remove all the non-speech segments from the label files. You will need also (but not necessary) to rename all the speech+music segments in speech segments. In some cases (not here), it can be better to merge successive speech and music+speech segments in order to have longer segments for the following steps.
#######
cat lblAcousticSegmentationWithMusic/$showname1$seg | sed 's/musicspeech/speech/g' | egrep -ve "music[0-9]+" > lblAcousticSegmentation/file.lbl

#######
#First step of the speaker diarization process : segmentation
#Resulting files are in the lblSegmentation directory
#######
./bin/Segmentation --config cfg/Segmentation.cfg --listFileToSegment ./lst/list.lst > log/Segmentation.log


#######
#Second step of the speaker diarization process : ReSegmentation
#Resulting files are in the lblReSegmentation directory
#######
./bin/ReSegmentation --config cfg/ReSegmentation.cfg --listFileToSegment ./lst/list.lst > log/ReSegmentation.log


#######
#To be able to use the NIST scoring script, segmentation file must follow the RTTM format. So, this binary converts the label file into RTTM file
#######
./bin/SpkMoulinette --filesList lst/list.lst --inputFormat LBL --inputFilesPath lblReSegmentation/ --inputFilesExtension .lbl --outputFormat RTTM --outputFilesPath rttmTmp/ --outputFilesExtension .rttm

