function [xw,w]=ngdpreprocbyzeroatpi(x,fs,N)

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
w=(2*(1+cos(n)));

xw=w(:).*x(:);
% figure;
% plot(w);
return;
