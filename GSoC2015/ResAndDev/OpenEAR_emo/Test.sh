#! /bin/bash

sh_pro(){
	cd $OPENEAR_WORKING_DIR
#SLASH="/"
	ffmpeg -i $1 -ac 2 -ar 16000 -vn test_full.wav

	./audiotrim.sh test_full.wav $2 $3 test_snip.wav
	cd $OPENEAR_SRC_DIR

#./SMILExtract -C /home/pydev/openEAR-0.1.0/config/emobase.conf -I /home/pydev/RHSOC/test_snip.wav -O /home/pydev/RHSOC/test_snip.arff
	./SMILExtract -C $OPENEAR_SRC_DIR/config/emobase.conf -I $OPENEAR_WORKING_DIR/test_snip.wav -O $OPENEAR_WORKING_DIR/test_snip.arff -instname inst1 -classes {Anger,Boredom,Disgust,Fear,Happiness,Neutral,Sadness}


	cd $OPENEAR_SRC_DIR/scripts/modeltrain
	perl arffToLsvm.pl $OPENEAR_WORKING_DIR/test_snip.arff $OPENEAR_WORKING_DIR/test_snip.lsvm

	cd $OPENEAR_WORKING_DIR
	svm-scale -s $OPENEAR_SRC_DIR/models/emo/emodb.emobase.scale test_snip.lsvm > test_snip.scaled.lsvm

	svm-predict -b 1 test_snip.scaled.lsvm $OPENEAR_SRC_DIR/models/emo/emodb.emobase.model resultOut

	rm test_snip.scaled.lsvm
	rm test_snip.lsvm
	rm test_snip.disc
	rm test_snip.classes
	rm test_snip.arff
	#rm test_full.wav
	#rm test_snip.wav
}

sh_pro
