#! /bin/bash

#ac 1 is mono
cd /home/pydev/RHSOC
ffmpeg -i 2015-06-02_0000_US_HLN_Nancy_Grace.mp4 -ac 2 -ar 16000 -vn test_full.wav

./audiotrim.sh test_full.wav 00:10:14 00:11:09 test_snip.wav
cd /home/pydev/openEAR-0.1.0

#./SMILExtract -C /home/pydev/openEAR-0.1.0/config/emobase.conf -I /home/pydev/RHSOC/test_snip.wav -O /home/pydev/RHSOC/test_snip.arff
./SMILExtract -C /home/pydev/openEAR-0.1.0/config/emobase.conf -I /home/pydev/RHSOC/test_snip.wav -O /home/pydev/RHSOC/test_snip.arff -instname inst1 -classes {Anger,Boredom,Disgust,Fear,Happiness,Neutral,Sadness}


cd /home/pydev/openEAR-0.1.0/scripts/modeltrain
perl arffToLsvm.pl ~/RHSOC/test_snip.arff ~/RHSOC/test_snip.lsvm

cd /home/pydev/RHSOC
svm-scale -s ~/openEAR-0.1.0/models/emo/emodb.emobase.scale test_snip.lsvm > test_snip.scaled.lsvm

svm-predict -b 1 test_snip.scaled.lsvm ~/openEAR-0.1.0/models/emo/emodb.emobase.model resultOut

rm test_snip.scaled.lsvm
rm test_snip.lsvm
rm test_snip.arff
