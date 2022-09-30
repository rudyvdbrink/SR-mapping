function [y, mu] = demean(x,dim)
%DEMEAN  De-mean a variable.
%   
%   y = DEMEAN(x) subtracts the mean of variable x from the elements in x.
%
%   [y, mu] = DEMEAN(x,dim) subtracts the mean along dimension dim and
%   returns the original mean mu. The default dimension that DEMEAN uses is
%   the first non-singleton dimension
%
%   See also MEAN
%
%   Rudy van den Brink, 2012

%% Check the input

if nargin > 2
    error('Im sorry Dave, but I cant let you do that. Provide two inputs max.')
end

%% Remove mean

% [] is a special case for mean, just handle it out here.
if isequal(x,[]), y = x; return; end

if nargin < 2
    % Figure out which dimension to work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

% Compute mean of x and subtract it
mu = mean(x,dim);
y  = bsxfun(@minus, x, mu);


end