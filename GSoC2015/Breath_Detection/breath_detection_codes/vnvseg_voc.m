function [vnvsig] = vnvseg_voc(s,zf,fs,nmean)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage:  [vnv,vnvevidence,filtsig] = vnvseg(wav,fs, ntrend);
%
% Description: This function computes the voicing strength of the given speech
%	signal 'wav' with sampling rate 'fs'. 'nmean' specifies the window
%	size in 'ms' for removing local mean.
%
% Authors: Dhananjaya N
% Algorithm: Sriram Murty and Professor
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(~exist('nmean'))
 nmean=10;
end;

%if(fs~=32000)
% fsold=fs;
% sold=s;
% fs=32000;
% s=resample(s,fs,fsold);
%end

s=s(:);
ds=diff(s);
ds(end+1)=ds(end);

% r = 0.98;
% f = 0;
% [B1,A1]=resonator(r,f,fs);
% 
% zf=filter(B1,A1,ds);
% zf=filter(B1,A1,zf);

%zf=zfsig(ds,fs);

% musig=RunMean(zf,floor(nmean*fs/1000));
% zf=zf-musig;
% 
% musig=RunMean(zf,floor(nmean*fs/1000));
% zf=zf-musig;
% 
% musig=RunMean(zf,floor(nmean*fs/1000));
% zf=zf-musig;
% 
% musig=RunMean(zf,floor(nmean*fs/1000));
% zf=zf-musig;


%if(exist('fsold'))
% zf=resample(zf,fsold,fs);
% s=resample(s,fsold,fs);
% fs=fsold;
%end

s=s/sqrt(sum(s.^2)/length(s));
ds=ds/sqrt(sum(ds.^2)/length(ds));
zf=zf/sqrt(sum(zf.^2)/length(zf));
% 
se=RunMean(ds.^2,nmean*fs/1000);
zfe=RunMean(zf.^2,nmean*fs/1000);

zfbys=zfe./se;
zfbysevi=-tansig(zfbys-10);
zfevi=1-exp(-10*zfe);
% 

%rse10=res2sig(ds,fs,10);                  % Comment if you want to use only voiced/unvoiced
%rse10=RunMean(rse10,20*fs/1000);	  % Comment if you want to use only voiced/unvoiced
%rse10evi=-tansig(10*(rse10-.5));	  % Comment if you want to use only voiced/unvoiced
% 
%vnvfevi = (zfevi+zfbysevi+rse10evi)/3;
vnvfevi=zfevi;
%vnvevi = [zfevi(:) zfbysevi(:) rse10evi(:)];
vnvsig=vnvfevi > 0.6; 
vnvsig=medfilt1(double(vnvsig),double(20*fs/1000));
vnvsig=vnvsig > 0.0;

return;
