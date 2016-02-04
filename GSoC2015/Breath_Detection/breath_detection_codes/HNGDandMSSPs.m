%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP:1 
%%%%%%%%%  THIS IS THE PROGRAM THAT CALCULATES THE 
%%%%%%%%%  ZTL AND THEN EXTRACT DRFs FROM THE SPECTRUM
%%%%%%%%%  AND WRITES THOSE TO A FILE
%%%%%%%%%  -- Author: RSP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[s1,pos1,hngdM] = HNGDandMSSPs(wav,fs,nwin) %nwin is in samples
   plotF=0;tic;
   hngdM = newZTL(wav,fs,nwin);
   %for first peak or 2 peaks
%    [s1 s3 pos1 pos3] = find2PEAKlocations(hngdM);        
%    pos2 = [pos1 pos3];
%    s2 = [s1 s3];
   pos1 = [];
   [s1 pos1] = find2PEAKlocations(hngdM,2);%%%%  changed from 1 to 2 to find
                                           %%%%  the 1st & 2nd DRF's
   if(plotF==1)
   plotFN(s1,pos1,wav,fs);  %%%%% hngdM,pos3,s3,s2,
   toc;
   end
 %_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    % New part doing the ZTL
    function[hngdM] = newZTL(y1,fs,nwin)
        nfft = 1024;
        temp = y1;
        lY1 = length(temp)-nwin;
        hngdM = zeros(nfft/2,lY1);
        for i=1:length(temp)-nwin
            y=temp(i:i+nwin-1);
            [yw,~]=ngdpreprocbyzeroatpi(y,fs,nwin);
            [yw,w2]=ngdpreprocbypoleat0(yw,fs,nwin);
            yw=ngdpreprocbypoleat0(yw,fs,nwin);
            [~,~,ngd,~,~]=gdelay1d(yw,nfft,fs,0.5);
            ngd=[ngd(:);ngd(:);ngd(:)];
            hngd=abs(hilbert(diff(diff(diff(ngd)))));
%             hngd=abs(hilbert(ngd));
            nfftby2=floor(nfft/2);
            hngd=hngd(nfft-4+[1:nfftby2+1]);
            hngdM(:,i)=hngd(1:512);
%             subplot(211);plot(y,'k');hold on; plot(w2/max(w2),'r');grid;
%             subplot(212);plot(hngdM(:,i),'k');
%             pause;
        end
        
        % normalization - dividing by sum of strength
        %  by sreedhar
        
%         hngdMT = hngdM;
% 
%         hngdsum = sum(hngdMT);
%         hngdsum = repmat(hngdsum,512,1);
% 
%         hngdMNew = hngdMT./hngdsum;
%         
%         hngdM = hngdMNew;
        
        %end of normalization
    end
    %_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    function[s1 pos1] = find2PEAKlocations(data,level)        
    data = data';
    [m n] = size(data);
    
    pos1 = zeros(m,1);
    pos3 = zeros(m,1);
    str1 = zeros(m,1);
    str3 = zeros(m,1);
    
    for index=1:m
    data1 = data(index,:);
    data_diff = diff(data1);
    data_diff_shift = circshift(data_diff,[1 1]);
    data_multiply = data_diff.*data_diff_shift;
    data_multiply(1)=0;
    data_multiply(end)=0;
    place = find(data_multiply<0);
    temp = zeros(size(data_multiply));
    temp(place) = data1(place);
    [f1 f2] = max(temp);   
    pos1(index,1)=f2;
    str1(index,1) = f1;
    if(level==2)
    temp(f2)=0; % modification for finding second DRF
%     temp(1:12)=0;
    [f3 f4] = max(temp);
    pos3(index,1)=f4;
    str3(index,1) = f3;
    end
    end
    if(level==2)
    pos1 = [pos1 pos3];
    s1 = [str1 str3];
    else
        s1 = str1;
    end
    end
    %_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    % Plotting Functions
    function[] = plotFN(s1,pos1,wav,fs)   %%%  hngdM,pos2,s2,s1,
        s11 =s1(:,1);
        s12 =s1(:,2); 
        pos2 = pos1(:,2);
        pos1 = pos1(:,1);
        n1 = length(pos1);
        
        figure;
        ax(1) = subplot(311);
%         plot((1:length(wav))/fs,wav/max(wav),'k');grid;xlim([0 length(wav)/fs]);
        plot(wav/max(wav),'k');xlim([0 length(wav)]);
        ax(2) = subplot(3,1,[2 3]);
        size(hngdM)
        surf(1:n1,1:8000/512:8000,hngdM);  
        colormap(flipud(gray));shading interp;axis xy;
        hold on;
        plot3(1:n1,pos1*8000/512,s1,'* r');
%         hold on;
%         plot3(1:n1,pos2*8000/512,s2,'* g');
          
%            ax(2) = subplot(722);
%           plot(pos1*8000/512,'.k');grid;
%           hold on; plot(pos2*8000/512,'.r');%%%(1:n1)/fs,
%           xlim([0 n1]);
%           ylim([0 2000]);
% %             hold on;
% %             plot(pos2*8000/512,'. r');
%            ax(3) = subplot(7,2,3);
%            plot(s11,'.k');grid;
%            ax(4) = subplot(724);
%            plot(s12,'.k');grid;
% %         figure;
%         ax(5) = subplot(7,1,[3 4 5 6 7]);
%         surf(1:n1,1:8000/512:8000,hngdM);ylim([1 2500]);     
%         colormap(flipud(gray));shading interp;axis xy;
%         view([-165 60]);
% %         hold on;
% %         plot3(1:n1,pos1*8000/512,s1,'* r');
% %         hold on;
% %         plot3(1:n1,pos2*8000/512,s2,'* g');
%         linkaxes(ax,'x');
    end

%_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

end