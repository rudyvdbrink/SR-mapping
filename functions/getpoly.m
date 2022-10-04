function y = getpoly(x,p)

% GETPOLY(x,p) gets the fitted polynomial with parameters p over data
% vector x. 
% 
% The parameters in p stem from polynomial fitting, should have the form:
% p(1)*x^n + p(2)*x^(n-1) +...+ p(n)*x + p(n+1)

%% compute

n = length(p)-1;
t = nan(n,length(x));
for ni = 1:n
   t(ni,:) = p(ni).*x.^(n-(ni-1)); 
end
y = sum(t,1) + p(end);

