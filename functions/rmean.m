function y = rmean(x,varargin)
%RMEAN  Mean for correlation coefficients
%   
%   RMEAN(x) is the same as MEAN(X), but first arc-sine transforms the
%   correlation coefficients before averaging, and then performs the
%   reverse transform. 
%
%   Rudy van den Brink, 2017
%     See also DEMEAN.

if ~isempty(varargin)
    y = tanh(nanmean(atanh(x),varargin{:}));
else
    y = tanh(nanmean(atanh(x)));
end

y = real(y);

end