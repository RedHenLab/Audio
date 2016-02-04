#!/bin/bash
cd /export/a09/dpovey/kaldi-clean/egs/librispeech/s5
. ./path.sh
( echo '#' Running on `hostname`
  echo '#' Started at `date`
  echo -n '# '; cat <<EOF
local/g2p.sh data/local/dict/g2p/vocab_autogen.$SGE_TASK_ID /export/a15/vpanayotov/data/g2p data/local/dict/g2p/lexicon_autogen.$SGE_TASK_ID 
EOF
) >data/local/dict/g2p/log/g2p.$SGE_TASK_ID.log
time1=`date +"%s"`
 ( local/g2p.sh data/local/dict/g2p/vocab_autogen.$SGE_TASK_ID /export/a15/vpanayotov/data/g2p data/local/dict/g2p/lexicon_autogen.$SGE_TASK_ID  ) 2>>data/local/dict/g2p/log/g2p.$SGE_TASK_ID.log >>data/local/dict/g2p/log/g2p.$SGE_TASK_ID.log
ret=$?
time2=`date +"%s"`
echo '#' Accounting: time=$(($time2-$time1)) threads=1 >>data/local/dict/g2p/log/g2p.$SGE_TASK_ID.log
echo '#' Finished at `date` with status $ret >>data/local/dict/g2p/log/g2p.$SGE_TASK_ID.log
[ $ret -eq 137 ] && exit 100;
touch data/local/dict/g2p/q/done.69003.$SGE_TASK_ID
exit $[$ret ? 1 : 0]
## submitted with:
# qsub -S /bin/bash -v PATH -cwd -j y -o data/local/dict/g2p/q/g2p.log -l arch=*64  -t 1:30 /export/a09/dpovey/kaldi-clean/egs/librispeech/s5/data/local/dict/g2p/q/g2p.sh >>data/local/dict/g2p/q/g2p.log 2>&1
