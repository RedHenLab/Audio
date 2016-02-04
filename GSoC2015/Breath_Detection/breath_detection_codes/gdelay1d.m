function [gd,f,ngd,mgd,mag,dmag,ldmag,nldmag] = gdelay1d(x,Nfft,fs,m)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Usage: [gd,f,ngd,mgd,dmag] = gdelay1d(x,Nfft,fs,m)
%
% 	Computes the group delay (GD) spectrum of a 1D signal. 
%
% Inputs:
% x 	- input signal
% Nfft	- determines the FFt length or the number of samples in the frequency 
%	domain over the range [0 2*pi] (default Nfft=length(x))
% fs	- sampling rate if 'f' the frequency indices at which the GD spectrum
%	is sampled.
% m	- modification factor for computing the modified group delay
%	(default m=0.5)
%
% Outputs:
% gd	- conventional group delay,
%	tau(w) = -d{theta(w)}/dw = Re{Y./X} = (Xr.*Yr + Xi.*Yi)./(|X|.^2)
%	where Y is the DFT of the signal y[n] = n * x[n];
% f	- frequency indices at which the GD spectrum is sampled.
% ngd	- numerator of the group delay,
%	tau_n(w) = tau(w) * |X|.^2 = (Xr.*Yr + Xi.*Yi)
% mgd	- modified group delay,
%	tau_m(w) = (Xr.*Yr + Xi.*Yi)./(|X|.^m)
%	where 'm' is the modification factor to condition the denominator
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mag= [];
NARGEXP = 4; % no. of arguments expected
if(nargin < 4)
 m = 0.5;
end
if(nargin < 3)
 fs = 8000;
end
if(nargin < 2)
 Nfft = length(x);
end 

f = [0:Nfft-1]*fs/Nfft;

% Check for zero signal
if(sum(x.^2)==0)
 gd = zeros(Nfft,1);
 ngd = zeros(Nfft,1);
 mgd = zeros(Nfft,1);
 return;
end

x = x(:);
X = fft(x,Nfft);

Nx = length(x);
n = [1:Nx]-1;
n = n(:);

y = n .* x;
Y = fft(y,Nfft);

Xr = real(X);
Xi = imag(X);
Xm = abs(X);
if(sum(Xm==0)>0)
    warning('Magnitude spectrum is zero at some frequencies. Fixing divide by zero error');
    Xm(find(Xm==0))=min(Xm(find(Xm~=0)));
end

Yr = real(Y);
Yi = imag(Y);

ngd = Xr.*Yr + Xi.*Yi;

gd = ngd./Xm.^2;

if(nargout>=4)
    mgd = ngd./Xm.^m;
end
if(nargout>=5)
    mag = Xm;
end
if(nargout>=6)
    nldmag = Xr.*Yi - Xi.*Yr;
    ldmag = nldmag./Xm.^2;
    dmag=nldmag./Xm;
end

return;
