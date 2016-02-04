function [yavg, ysum] = RunMean(sig, N, wintype)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Usage : [yavg,ysum] = RunMean(sig, N, wintype)
% 
% OUTPUTS	:
%	yavg	- running mean of the signal
%	ysum	- running sum of the signal 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if( ~ exist('wintype'))
	wintype	= 'RECT';
end

M	= length(sig);
Nby2	= floor(N/2);
Ntail	= N - Nby2 - 1; 

switch wintype
	case {'REC', 'RECT', 'rec', 'rect', '1'}
		h	= ones(N,1);

	case {'HAM', 'HAMM', 'ham', 'hamm', '2'}
		h	= hamming(N);

	case {'HAN', 'HANN', 'han', 'hann', '3'}
		h	= hanning(N);

	otherwise
		disp('Error : Unknown window type!!!');
		exit(1);
end

x	= conv(sig,h);
ysum	= x(Nby2+1:M+N-1-Ntail);

xdiv	= conv(ones(size(sig)),h);
x	= x ./ xdiv;
yavg	= x(Nby2+1:M+N-1-Ntail);

return;
