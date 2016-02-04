function [hngd,f] = ztl(x,fs,nfft,nwin,PLOTFLAG)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage: [hngd,f,dngd,ngd,mag,hgd,dgd,gd] = ztl(x,fs,nfft,nwin,PLOTFLAG)
%
% Preemphasis assumed to be done a priori
% [s,fs]=wavread('~/myrecordings/timit-train-dr1-mgrl0-sa2.wav');
% s=resample(s,10000,fs);
% fs=10000;
% n=2500;for i=n+[1:1000];x=s(i:i+50-1);[hngd,f,dngd,ngd,mag,hgd,dgd,gd] = ztl(x,fs,nfft,nwin,1);pause;end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(~exist('nfft'))
    nfft=2^11;
end
n1ms=round(fs/1000);
if(~exist('nwin'))
    nwin=5*n1ms;
end
nfftby2=floor(nfft/2);
Nx=length(x);

[xw,w1]=ngdpreprocbyzeroatpi(x,fs,nwin);
% [xw,w2]=ngdpreprocbypoleat0(xw,fs,nfft);
% xw=ngdpreprocbypoleat0(xw,fs,nfft);
[xw,w2]=ngdpreprocbypoleat0(xw,fs,nwin);
xw=ngdpreprocbypoleat0(xw,fs,nwin);

w=w1(1:nwin).*w2(1:nwin).^2;
%[ngd,f]=ngdspectrum(xw,fs,nfft);

[gd,f,ngd,mgd,mag]=gdelay1d(xw,nfft,fs,0.5);

ngd=[ngd(:);ngd(:);ngd(:)];
gd=[gd(:);gd(:);gd(:)];

dngd=-diff(diff(ngd));
dgd=-diff(diff(gd));

hngd=abs(hilbert(diff(dngd)));
hgd=abs(hilbert(diff(dgd)));

% hngd=abs(hilbert(diff(diff(dngd))));
% hgd=abs(hilbert(diff(diff(dgd))));

% hngd=abs(hilbert(diff(diff(diff(dngd)))));
% hgd=abs(hilbert(diff(diff(diff(dgd)))));

% hngd1=abs(hilbert((dngd)));
% hgd1=abs(hilbert((dgd)));
% hngd1=hngd1(1:nfftby2+1);
% hgd1=hgd1(1:nfftby2+1);
% hngd1=hngd1(:);
% hgd1=hgd1(:);

f=f(1:nfftby2+1);

ngd=ngd(1:nfftby2+1);%% becoz of symmetry only haly no. of values +1 are considered.
gd=gd(1:nfftby2+1);
mag=mag(1:nfftby2+1);

dngd=dngd(nfft-2+[1:nfftby2+1]);
dgd=dgd(nfft-2+[1:nfftby2+1]);

hngd=hngd(nfft-4+[1:nfftby2+1]);
hgd=hgd(nfft-4+[1:nfftby2+1]);

f=f(:);
hngd=hngd(:);
dngd=dngd(:);
ngd=ngd(:);
mag=mag(:);
dgd=dgd(:);
hgd=hgd(:);
gd=gd(:);
Xm=magspectrum(x(:).*hamming(length(x)),fs,nfft);
Xm=Xm(:);

%PLOTFLAG=1;
if(exist('PLOTFLAG') & PLOTFLAG==1)
    
    tx=[0:Nx-1]/fs*1000;
    tw=[0:length(xw)-1]/fs*1000;
    nr=3;nc=2;cp=1;
    fig=figure(1);clear ax;
    applytofig(fig,'width',20,'height',12,'color','cmyk');
    ax(cp)=subplot(nr,nc,cp);plot(x/max(abs(x)));cp=cp+1;ylabel('s[n]');axis tight;text(20,.8,'Speech waveform');
    ax(cp)=subplot(nr,nc,cp);plot(ngd);cp=cp+1;ylabel('g[k]');axis tight;
    ax(cp)=subplot(nr,nc,cp);plot(w);cp=cp+1;ylabel('w[n]');axis tight;text(20,8e4,'Liftering function');
    ax(cp)=subplot(nr,nc,cp);plot(dngd);cp=cp+1;ylabel('g_d[k]');axis tight;
    ax(cp)=subplot(nr,nc,cp);plot(xw);cp=cp+1;ylabel('x[n]');xlabel('n');axis tight; text(20,-500,'Liftered speech');   
    ax(cp)=subplot(nr,nc,cp);plot(hngd);cp=cp+1;ylabel('\psi[k]');xlabel('k');axis tight;
    
    for i=1:4;set(ax(i),'xticklabel',[]);end
    xbeg1=0.1;xbeg2=0.55;xwidth=0.35;ybeg=0.1;
    ybuff=[0 .05 .05];
    yheight=[0.23 .23 .24];
    for i=nr:-1:1
        set(ax(2*i-1),'position',[xbeg1,ybeg,xwidth,yheight(i)]);
        set(ax(2*i),'position',[xbeg2,ybeg,xwidth,yheight(i)]);
        ybeg=ybeg+yheight(i)+ybuff(i);
    end
    
    allText   = findall(fig, 'type', 'text');
    allAxes   = findall(fig, 'type', 'axes');
    allFont   = [allText; allAxes];
    set(allFont,'FontSize',12,'fontweight','bold');

    alllines=findall(fig,'type','line');
    set(alllines,'linewidth',1.5);
    %%%%%%%%%%%%%%%%%%%%%

%     tx=[0:Nx-1]/fs*1000;
%     tw=[0:length(xw)-1]/fs*1000;
%     nr=5;nc=2;cp=1;
%     fig=figure(2);clear ax;
%     applytofig(fig,'width',20,'height',25,'color','cmyk');
%     ax(cp)=subplot(nr,nc,cp);plot(tx,x);cp=cp+1;ylabel('s[n]');xlabel('nT (ms)');axis tight;
%     ax(cp)=subplot(nr,nc,cp);plot(tw,xw);cp=cp+1;ylabel('x[n]');xlabel('nT (ms)');axis tight;
%     %hold;plot(tw,w,'r');
%     
%     ax(cp)=subplot(nr,nc,cp);plot(f/1000,Xm);cp=cp+1;ylabel('|S(f)|');axis tight;
%     ax(cp)=subplot(nr,nc,cp);plot(f/1000,mag);cp=cp+1;ylabel('|X(f)|');axis tight;
% 
%     ax(cp)=subplot(nr,nc,cp);plot(f/1000,ngd);cp=cp+1;ylabel('g(f)');axis tight;
%     ax(cp)=subplot(nr,nc,cp);plot(f/1000,gd);cp=cp+1;ylabel('\tau(f)');axis tight;
% 
%     ax(cp)=subplot(nr,nc,cp);plot(f/1000,dngd);cp=cp+1;ylabel('g^\prime^\prime(f)');axis tight;
%     ax(cp)=subplot(nr,nc,cp);plot(f/1000,dgd);cp=cp+1;ylabel('\tau^\prime^\prime(f)');axis tight;
% 
% %     %ax(cp)=subplot(nr,nc,cp);plot(f/1000,hngd1);cp=cp+1;ylabel('g_h^\prime^\prime(f)');axis tight;
% %     %ax(cp)=subplot(nr,nc,cp);plot(f/1000,hgd1);cp=cp+1;ylabel('\tau_h^\prime^\prime(f)');axis tight;
% 
%     ax(cp)=subplot(nr,nc,cp);plot(f/1000,hngd);cp=cp+1;ylabel('g_h^\prime^\prime^\prime(f)');xlabel('f (kHz)');axis tight;
%     ax(cp)=subplot(nr,nc,cp);plot(f/1000,hgd);cp=cp+1;ylabel('\tau_h^\prime^\prime^\prime(f)');xlabel('f (kHz)');axis tight;
%     
%     for i=3:8;set(ax(i),'xticklabel',[]);end
%     xbeg1=0.1;xbeg2=0.55;xwidth=0.35;ybeg=0.1;
%     ybuff=[0 .055 0.015 .015 0.015];
%     yheight=[0.1 .15 .15 .15 .15];
%     for i=nr:-1:1
%         set(ax(2*i-1),'position',[xbeg1,ybeg,xwidth,yheight(i)]);
%         set(ax(2*i),'position',[xbeg2,ybeg,xwidth,yheight(i)]);
%         ybeg=ybeg+yheight(i)+ybuff(i);
%     end
% 
%     linkaxes(ax(3:end),'x')
%     allText   = findall(fig, 'type', 'text');
%     allAxes   = findall(fig, 'type', 'axes');
%     allFont   = [allText; allAxes];
%     set(allFont,'FontSize',8,'fontweight','bold');
% 
%     alllines=findall(fig,'type','line');
%     set(alllines,'linewidth',1.5);
    
    
end


return;