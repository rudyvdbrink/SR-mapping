function y = polyplot(x,p,plotopts)
% POLYPLOT(x,p) plots the fitted polynomial with parameters p over data
% vector x. 
% 
% The parameters in p stem from polynomial fitting, should have the form:
% p(1)*x^n + p(2)*x^(n-1) +...+ p(n)*x + p(n+1)
%
% y = polyplot(x,p) gets the fitted polynomial
% polyplot(x,p,plotopots) allows you to change plotting options

%% check input

defaultopts={'--k'};
if nargin<3 
    plotopts=defaultopts; 
end

if isempty(plotopts)
    plotopts=defaultopts; 
end

if ~iscell(plotopts)
    plotopts={plotopts}; 
end

%% compute

n = length(p)-1;
t = nan(n,length(x));
for ni = 1:n
   t(ni,:) = p(ni).*x.^(n-(ni-1)); 
end
y = sum(t,1) + p(end);

%% plot

plot(x,y,plotopts{:});