%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code is used for finding strengths of excitation from ZFR Signal
% other programs:
%	epochExtract with winLength as one of the recived argument	
% No need give 8k sampling frequency signal	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function [wav,fs,vnv,pstats,ststats,stSig,gci,pc]=modepochStrengthExtract(wavFile)
function [zfSig,vnv,vgci,vpc,st,gci]=epochStrengthExtract_voc(wav,fs)

% Read the speech signal...
%	wavFile
%	[wav fs]=wavread(wavFile);
%	if (fs ~= 8000)	
%		wav=resample(wav,8000,fs);
%		fs=8000;
%	end

	
	
% Finding the zero frequency Signal and gci 
	[zfSig, gci, winLength]=epochExtract(wav,fs);
		
	winLength

%	wav1=resample(wav,8000,16000); %vnvseg works best for 8k.
	[vnvsig] = vnvseg_voc(wav,zfSig,fs,winLength);

%%%%%%%%% vnvsig obtained from vnvseg is in 8k format. So converting it into 16k 
%	i=[1:length(vnvsig)];
%	vnv(2*i)=vnvsig(i);
%	vnv(2*i-1)=vnvsig(i);
%	vnv=vnv(1:length(wav));
%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%% Obtaining voiced pitch contour only
	vnv=vnvsig;	
	t=zeros(length(wav),1);t(gci)=1;
	vgci=find(vnv.*t); %vgci is gci's in voiced regions only

	pc=diff(gci);pc=[pc' pc(end)]; %pc means pitch contour
	t(gci)=pc;
	k=vnv.*t;
	vpc=t(find(k)); %vpc means voiced pitch contour
	vpc=vpc/8;
%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Getting voiced strengths
	st=zfSig(vgci+1)-zfSig(vgci-1);

%%%%%%%%%%%%%%%%%%%%%
% 	plotFlag=1;
% 
% 	if plotFlag == 1
% 	
% 	figure;
% 	ax(1)=subplot(311);plot([1:length(wav)]/fs,wav);hold on;plot([1:length(wav)]/fs,vnv*max(abs(wav)),'k');grid;
% 	ax(2)=subplot(312);plot([1:length(wav)]/fs,wav);hold on;stem(gci/fs,ones(1,length(gci))*max(abs(wav)));grid;
% 	ax(3)=subplot(313);plot([1:length(wav)]/fs,wav);hold on;stem(vgci/fs,ones(1,length(vgci))*max(abs(wav)));grid;
% 	linkaxes(ax,'x');
% 
% 	figure;
% 	ax(1)=subplot(411);plot([1:length(wav)]/fs,wav);hold on;plot([1:length(wav)]/fs,vnv*max(abs(wav)),'k');grid;
% 	ax(2)=subplot(412);plot([1:length(wav)]/fs,wav);hold on;stem(vgci/fs,ones(1,length(vgci))*max(abs(wav)));grid;
% 	ax(3)=subplot(413);plot(vgci/fs,vpc,'.');grid;
% 	ax(4)=subplot(414);plot(vgci/fs,st,'.');grid;
% 	linkaxes(ax,'x');
% 	end
	

	
	
end
