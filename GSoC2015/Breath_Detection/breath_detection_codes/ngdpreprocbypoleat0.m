function [xw,w]=ngdpreprocbypoleat0(x,fs,N)

% weight by 1/(4*sin^2(w)) , assume N=20 ms; eg: 320 at 16kHz.

n1ms=round(fs/1000);
if(~exist('N'))
    N=5*n1ms;
end

if(length(x)>N)
    x(N+1:end)=[];
else
    x(end+1:N)=0;
end

n=pi*[0:N-1]/N;
w=1./(2*(1-cos(n)));
w(1)=0;

xw=w(:).*x(:);
% figure;
% plot(w,'r');
% hold on; 
% plot(xw,'k');
return;
