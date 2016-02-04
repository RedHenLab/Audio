#!/bin/bash 
###############################################################################################
# I/P: data_for_TTS/wav/ 
# O/P: data_for_TTS/etc/txt.done.data and data_for_TTS/lab_{wd/phn}_level/
#
#     This script performs the following steps
# (1) Prepares data 
# (2) Prepares LM
# (3) Extracts MFCC features for audiobook data
# (4) Decodes audiobook data using acoustic model trained on 100 hrs of clean Librispeech data
# (5) Adapts acoustic model to the audio book data and decodes again (OPTIONAL) 
###############################################################################################

expt_name=$1
spk_gender=$2
Ngram=$3 
num_free_CPUs=$4
adapt=$5 

. ./cmd.sh 
. ./path.sh 

echo "Running scripts/run_kaldi/run_kaldi.sh ..."
echo ""; echo ""; echo ""

# (1) Prepare data
rm -r data/test data/train data/lang data/lang_test_Wug
mkdir data/test data/train data/lang data/lang_test_Wug
ls $PWD/../../data_for_TTS/wav/*.wav | sed 's/\(.*\)\/\(.*\).wav/\2\t\1\/\2.wav/;' > data/test/wav.scp
cut -f 1 data/test/wav.scp | sed 's/\(.*\)_\(.*\)/\1_\2 \1/' > data/test/utt2spk
utils/utt2spk_to_spk2utt.pl data/test/utt2spk > data/test/spk2utt
echo "$expt_name $spk_gender" > data/test/spk2gender
echo "junk" > data/test/text

 
# (2) Prepare LM 
srcdir=data/local/data
dir=data/local/dict
lmdir=data/local/lm
tmpdir=data/local/lm_tmp

mkdir -p $tmpdir $lmdir

# I/P: $srcdir/lm_train.txt, O/P: Ngram freqs. in ARPA format
# $srcdir/lm_train.txt is the raw input (containing word sequences) for preparing LM.
# Currently, a uniform freq. distribution over words in dict, and Ngram=1 is set to 
# attempt to nullify the effect of LM, and to base the recognition decision purely on 
# acoustics. Uniform freq. distribution over words in dict is achieved by having 
# just one entry of each word in $srcdir/lm_train.txt
rm $tmpdir/lm_Wug.ilm.gz
./build-lm.sh -i $srcdir/lm_train.txt -n $Ngram -o $tmpdir/lm_Wug.ilm.gz
rm $lmdir/lm_Wug.arpa.gz
compile-lm $tmpdir/lm_Wug.ilm.gz --text=yes /dev/stdout | \
  grep -v unk | gzip -c > $lmdir/lm_Wug.arpa.gz

# Prepare data/lang which contains lexicon FST (L.fst)
rm -r data/local/lang_tmp data/lang
utils/prepare_lang.sh data/local/dict "SIL" data/local/lang_tmp data/lang

# Prepare data/lang_test_Wug which contains grammar FST (G.fst)
rm -r data/lang_test_Wug
local/format_lms.sh data/local/lm   


# (3) Extract MFCCs for audiobook data
steps/make_mfcc.sh --cmd "run.pl" --nj $num_free_CPUs data/test exp/make_mfcc/test mfcc
steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test mfcc


# (4) Decode audiobook data using acoustic model trained on 100 hrs of clean Librispeech data
rm -r data/test/split* 
./utils/split_data.sh data/test $num_free_CPUs
rm -r exp/tri2b/graph_Wug
utils/mkgraph.sh data/lang_test_Wug exp/tri2b exp/tri2b/graph_Wug   # make decoding graph (HCLG.fst)
steps/decode.sh --nj $num_free_CPUs --cmd "run.pl" \
   exp/tri2b/graph_Wug data/test exp/tri2b/decode_test              # decode

if [ $adapt = "no" ]; then
   ./utils/int2sym.pl -f 2-  data/lang_test_Wug/words.txt  exp/tri2b/decode_test/scoring/10.tra | \
      sort | sed 's/ SIL / /g; s/ / " /; s/^/( /; s/$/ ")/;' > ../../data_for_TTS/etc/txt.done.data
   ./output_lab_and_confidence_info.sh tri2b $num_free_CPUs     # output lab_{phn_level/wd_level}
fi 


# (5) Adapt acoustic model to the audio book data and decode again
if [ $adapt = "yes" ]; then 
   cp -r data/test/* data/train/
   ./utils/int2sym.pl -f 2-  data/lang_test_Wug/words.txt  exp/tri2b/decode_test/scoring/10.tra | \
     sort | sed 's/ SIL / /g'  > data/train/text
   rm -r data/train/split*
   ./utils/split_data.sh data/train $num_free_CPUs 
 
   # get alignment between text and audio for training
   steps/align_si.sh  --nj $num_free_CPUs --cmd "run.pl" \
     --use-graphs false data/train data/lang exp/tri2b exp/tri2b_ali_emma 
 
   # Train tri3b, which is LDA+MLLT+SAT
   steps/train_sat.sh --cmd "run.pl" \
     2500 15000 data/train data/lang exp/tri2b_ali_emma exp/tri3b
   rm -r exp/tri3b/graph_Wug 
   utils/mkgraph.sh data/lang_test_Wug exp/tri3b exp/tri3b/graph_Wug # make decoding graph (HCLG.fst)
   steps/decode.sh --nj $num_free_CPUs --cmd "run.pl" \
     exp/tri3b/graph_Wug data/test exp/tri3b/decode_test             # decode
 
   ./utils/int2sym.pl -f 2-  data/lang_test_Wug/words.txt  exp/tri3b/decode_test/scoring/10.tra | \
      sort | sed 's/ SIL / /g; s/ / " /; s/^/( /; s/$/ ")/;' > ../../data_for_TTS/etc/txt.done.data
   ./output_lab_and_confidence_info.sh tri3b $num_free_CPUs     # output lab_{phn_level/wd_level}
fi
