#!/usr/bin/perl -w 

if ($#ARGV != 1) {
  print "Usage:   $0  dbName JOB\n"; 
  print "Example: $0  sgmm2_4 1\n"; 
  exit; 
}

($dbName, $JOB)=@ARGV; 

open CONF, "< $dbName/$JOB.phones.conf"; 
open CTM, "< $dbName/$JOB.1best-to-ctm.txt"; 
open CTM_CONF, "> $dbName/$JOB.1best-to-ctm.txt.conf"; 

while (<CONF>) {
  chomp;
  $_ =~ /^(.+?)\s+\[\s+(.+?)\s+\]\s*$/;  
  @frame_conf_utt=split/\s+/, $2; 
  $frame_no=0;
  while ($ctm=<CTM>) {
    chomp $ctm;
    $ctm =~ s/\s+$//;
    $ctm =~ /(.+?)\s+.+?\s+(.+?)\s+(.+?)\s+(.+)/;
    $utt_id=$1; $st=$2; $dur=$3; $ph=$4;
    $et=$st+$dur; $et=sprintf("%0.2f",$et); $utt_id=uc($utt_id);
    @frame_conf_segment=(); 
    @frame_conf_segment = @frame_conf_utt[$frame_no..($frame_no+$dur*100)-1];
    $frame_no+=$dur*100;  
    $avg_conf = &avg(@frame_conf_segment); $avg_conf=sprintf("%0.2f",$avg_conf);
    print CTM_CONF "$utt_id $et 125 $ph $avg_conf\n";
    last if ($frame_no > $#frame_conf_utt); 
  }
}

sub avg () {
  @g = @_; #print "@g\n";  
  $sum=0; $frame_conf_utt_len=0;  
  foreach $element (@g) {
    $sum+=$element; 
    $frame_conf_utt_len++; 
  }
  $avg=$sum/$frame_conf_utt_len;
  return $avg; 
}

close CONF; 
close CTM; 
close CTM_CONF; 
