%function [zfSig, gci, winLength]=epochExtract(wavFile)
function [zfSig, gci, winLength]=epochExtract(wav,fs)

% function [gci]=epochExtract(wav, fs)
% zfSig is the zero frequency signal derived from speech signal.
% gci is the glottal closure instant timing in seconds.

%% Read the speech signal...
%	[sph fs1]=wavread(wavFile);
%	wav=resample(sph,16000,fs1);
%	fs=16000;
%	wav=resample(sph,8000,fs1);
%	fs=8000;
%	disp('Sampling Frequency:');fs

% Find the average pitch period (in ms) for trend removal...
	winLength=xcorrWinLen(wav,fs);
%	winLength=4;
% Derive the zero-frequency filered signal... 	
	zfSig=zeroFreqFilter(wav,fs,winLength);
	
%	vad=getVad(zfSig,fs);
%%%%%%%%%%%%%%% vad is obtained using features from voice bar %%%%%%%%%%%%%%%%
	
%	sph1=resample(sph,8000,fs1);
%	[vnv,vnvevi,zf]=vnvseg(wav,fs,10);
	

%%%%%%%%%%%%%%% vad is obtained using features from voice bar %%%%%%%%%%%%%%%%

%%%%%%%%%%%% Detect the polarity of the signal and correct it%%%%%%%%%%%%%%%%	
	[pzc pslope]=zerocros(zfSig,'p');
	[nzc nslope]=zerocros(zfSig,'n');
	
	l=min(length(pzc),length(nzc));
    
	dslope=abs(pslope(1:l))-abs(nslope(1:l));
	if(sum(dslope>0)>length(dslope)/2)
		gci=pzc;
%		disp('Polarity of the signal: +ve');
	else
		gci=nzc;
		wav=-wav;
		zfSig=-zfSig;
%		disp('Polarity of the signal : -ve');
	end;

%	p=zeros(length(wav)-1,1); p(gci)=1; p=p.*vad; gci=find(p==1); %uncomment if u want instants in voiced regions only
	p=zeros(length(wav)-1,1); p(gci)=1; p=p; gci=find(p==1);
	
    plotFlag=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	gci=gci+3;
    
    if plotFlag==1

	figure; 
	ax(1)=subplot(2,1,1); plot((1:length(wav))/fs, wav/max(abs(wav))); grid;hold on;
	x=[gci(:)'/fs;gci(:)'/fs];
	y=[ones(1,length(gci))*2;ones(1,length(gci))*0.2];
	line(x,y,'color','r','marker','v'); 
	ylim([-1 1]); 
	title('Speech signal with hypothesized GCIs');
	ax(2)=subplot(2,1,2); plot((1:length(zfSig))/fs,zfSig/max(abs(zfSig)));grid;
	ylim([-1 1]);
	xlabel('Time (s)');
	title('Zero-frequency Filtered signal');
	linkaxes(ax,'x');
	xlim([0 (length(wav)-winLength*3)/fs]);

	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	figure;
	ax(1)=subplot(2,1,1); plot((1:length(wav))/fs, wav/max(abs(wav))); grid;
	ylim([-1 1]);
	title('Speech signal with hypothesized GCIs');

	ax(2)=subplot(2,1,2); plot((1:length(zfSig))/fs,zfSig/max(abs(zfSig)));grid;
	ylim([-1 1]);
	xlabel('Time (s)');
	title('Zero-frequency Filtered signal');
	linkaxes(ax,'x');
	xlim([0 (length(wav)-winLength*3)/fs]);
	
	
    end
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [zfSig]=zeroFreqFilter(wav,fs,winLength)
% Difference the speech signal...
	dwav=diff(wav);dwav(end+1)=dwav(end);
	dwav=dwav/max(abs(dwav));
%	dwav=wav;
	N=length(dwav);
% If using Edirol with low cut off on diff(wav) should not be used 
%	dwav=wav(1:end-1);
%	dwav=dwav/max(abs(dwav));
%	N=length(dwav);
% Pass the differenced speech signal twice through zero-frequency resonator..	
	zfSig=cumsum(cumsum(cumsum(cumsum(dwav))));

%	figure; 
%	ax(1)=subplot(5,1,1); plot((1:length(wav))/fs, wav/max(abs(wav))); grid;
%	title('Speech signal');

%% Remove the DC offset introduced by zero-frquency filtering..	
	winLength=round(winLength*fs/1000);
%	ax(2)=subplot(5,1,2); plot((1:length(zfSig))/fs,zfSig);grid;
%	title('Output of cascade of zero frequency resonators, y2[n]');
	zfSig=remTrend(zfSig,winLength);
	temp=zfSig; %temp(N-winLength:N)=0;
%	ax(3)=subplot(5,1,3); plot((1:length(temp))/fs,temp);grid;
%	title('Output after first trend removal');
	zfSig=remTrend(zfSig,winLength);
	temp=zfSig; %temp(N-winLength*2:N)=0;
%	ax(4)=subplot(5,1,4); plot((1:length(temp))/fs,temp);grid;
%	title('Output after second trend removal');
	zfSig=remTrend(zfSig,winLength);
	temp=zfSig; %temp(N-winLength*2:N)=0;
%	ax(4)=subplot(5,1,4); plot((1:length(temp))/fs,temp);grid;
%	title('Output after second trend removal');
	zfSig=remTrend(zfSig,winLength);
	zfSig(N-winLength*3:N)=0;
%	ax(5)=subplot(5,1,5); plot((1:length(zfSig))/fs,zfSig/max(abs(zfSig)));grid;
%	title('Output after third trend removal');
%	xlabel('Time (s)');
%	linkaxes(ax,'x');
%	xlim([0 (N-winLength*3)/fs]);
	
	
function [out]=remTrend(sig,winSize);

%	for i=1:40:length(sig)
%		figure;
%		plot(sig(i:i+40));
%		pause;
%	end
	
	window=ones(winSize,1);
	rm=conv(sig,window);
	rm=rm(winSize/2:length(rm)-winSize/2);


	norm=conv(ones(length(sig),1),window);
	norm=norm(winSize/2:length(norm)-winSize/2);
	
	rm=rm./norm;
%
%	for i=1:40:length(rm)
%		figure;
%		plot(rm(i:i+40));
%		pause;
%	end
%

	out=sig-rm;

function [f,s]=zerocros(x,m)
	if nargin<2
    		m='b';
	end
	s=x>=0;
	k=s(2:end)-s(1:end-1);
	if any(m=='p')
  		f=find(k>0);
	elseif any(m=='n')
	    f=find(k<0);
	else
	    f=find(k~=0);
	end
	s=x(f+1)-x(f);

function [idx]=xcorrWinLen(wav,fs)

%	zfSig=zeroFreqFilter(wav,fs,2);
%	zfSig=zfSig/max(abs(zfSig));
%	wav=zfSig;

	frameSize=30*fs/1000;
	frameShift=20*fs/1000;

	en=conv(wav.^2,ones(frameSize,1));
	en=en(frameSize/2:end-frameSize/2);
	en=en/frameSize;
	en=sqrt(en);
	en=en>max(en)/5;

	b=buffer(wav,frameSize,frameShift,'nodelay');
	vad=sum(buffer(en,frameSize,frameShift,'nodelay'));

	FUN=@(x) xcorr((x-mean(x)).*hamming(length(x)),'coeff')./xcorr(hamming(length(x)),'coeff');
	out=blkproc(b,[frameSize,1],FUN);

	out=out(frameSize:end,:);
	
	minPitch=3;  %2 ms == 500 Hz.
       	maxPitch=16; %16 ms == 66.66 Hz.	

	[maxv maxi]=max(out(minPitch*fs/1000:maxPitch*fs/1000,:));

	%h=hist(maxi(vad>frameSize/2)+minPitch,(3:15)*8-4);
	x=(minPitch:0.5:maxPitch)*fs/1000+2;
	pLoc=maxi(vad>frameSize*0.8)+minPitch*fs/1000;
	y=hist(pLoc,x);
	y=y/length(pLoc);
	
	%bar(x,y,1,'EdgeColor',[1 1 1],'FaceColor',[0 0 0]);
	%set(gca,'xTick',(1:maxPitch)*fs/1000+0.5*fs/1000, 'xTickLabel',(1:maxPitch));
	%set(gca,'yTick',[0 0.1 0.2 0.3 0.4],'yTickLabel',[0 0.1 0.2 0.3 0.4]);
	%xlabel('Time (s)');
	%ylabel('Normalized frequency');
        %allText   = findall(h, 'type', 'text');
        %allAxes   = findall(h, 'type', 'axes');
        %allFont   = [allText; allAxes];
	%xlim([1 maxPitch+1]*fs/1000)
        %set(allFont,'FontSize',18);

	%advexpfig(h,'hist.eps','-deps2c','w',20,'h',20);

	%close(h);

	[val idx]=max(y);
	idx=round(idx/2)+minPitch+2;
function [vad]=getVad(sig,fs)

	winLength=20*fs/1000;
	en=conv(abs(sig),ones(winLength,1));
	en=en(winLength/2:length(en)-winLength/2);
	en=en/max(en);

	%figure; plot(sig); hold on; plot(en/max(abs(en)),'r');

	vad=en>0.1;
