function stats = permtestnds(a,varargin)
%   Non-parametric permutation test to compare means using
%   within-participant shuffling. Use as a paired-sample permutation test.
%
%   This version reports descriptive statistics.
%
%   H0: the two populations have equal means
%   HA: the two populations have unequal means
%
%   Usage:
%     stats = permtestnds(a)                          (compare to zero)
%     stats = permtestnds(a,b)                        (compare to a particular value, or compare the mean of two distributions)
%     stats = permtestnds(a,b,npermutes,pthresh,tail,dim)
%
%   Input:
%     a:          distribution 1
%     b:          (optional) distribution 2, or a single value. default: 0
%     npermutes:  (optional) the number of permutations. default: 1000
%     pthresh:    (optional) the p-threshold for significance. default: 0.05
%     tail:       (optional) test one-tailed (specify 'right' or 'left') or two-tailed (specify 'both'). default: two-tailed
%                   if there is no a priori expectation, then use 'tail' = 'both'
%                   if the a priori expectation is that a > b, then use 'tail' = 'right'
%                   if the a priori expectation is that a < b, then use 'tail' = 'left'
%     dim:        (optional) dimension across which to test. default: 1
%
%   Output:
%     stats.h:       significance (1 or 0)
%     stats.p:       p-value of permutation test. Discard H0 if pval is small.
%     stats.d:       Cohen's d
%     stats.CI:  	 95% CI around mean difference
%
%   Notes:
%      d > 0.01: very small effect size
%      d > 0.20: small effect size
%      d > 0.50: medium effect size
%      d > 0.80: large effect size
%      d > 1.20: very large effect size
%      d > 2.00: huge effect size
%   See: Sawilowsky, S (2009). New effect size rules of thumb. Journal of Modern Applied Statistical Methods. 8 (2): 467?474.
%
% RL van den Brink, 2022

%% check input
if isempty(varargin) || nargin == 1
    b = zeros(size(a));
    npermutes = 1000;
    pthresh   = 0.05;
    tail = 'both';
    dim = 1;
else    
    if nargin == 0
        error('not enough input arguments')
    elseif nargin == 2
        npermutes = 1000;
        pthresh   = 0.05;
        tail = 'both';
        b = varargin{1};
        dim = 1;
    elseif nargin == 3
        pthresh   = 0.05;
        b = varargin{1};
        npermutes = varargin{2};
        tail = 'both';
        dim = 1;
    elseif nargin == 4
        b = varargin{1};
        npermutes = varargin{2};
        pthresh = varargin{3};
        tail = 'both';
        dim = 1;
    elseif nargin == 5
        b = varargin{1};
        npermutes = varargin{2};
        pthresh = varargin{3};
        tail = varargin{4};
        dim = 1;
    elseif nargin > 6
        error('too many input arguments')
    else
        b = varargin{1};
        npermutes = varargin{2};
        pthresh = varargin{3};
        tail = varargin{4};
        dim = varargin{5};
    end
end


if ~isvector(a) || ~isvector(b)
    error('Matrix input is not supported')
end

[h, p, diff, diff_null] = permtestn(a,b,npermutes,pthresh,tail,dim);

stats.h   = h;
stats.p   = p;
stats.d   = computeCohen_d(a,b,'paired');
stats.CI  = diff+[prctile(diff_null,5) prctile(diff_null,95)];


disp(['p = '  num2str(p) '; 95% CI: ' num2str(stats.CI(1)) '-' num2str(stats.CI(2)) '; Cohen`s d: ' num2str(stats.d)]) 

end



function d = computeCohen_d(x1, x2, varargin)
%
% call: d = computeCohen_d(x1, x2, varargin)
%
% EFFECT SIZE of the difference between the two
% means of two samples, x1 and x2 (that are vectors),
% computed as "Cohen's d".
%
% If x1 and x2 can be either two independent or paired
% samples, and should be treated accordingly:
%
%   d = computeCohen_d(x1, x2, 'independent');  [default]
%   d = computeCohen_d(x1, x2, 'paired');
%
% Note: according to Cohen and Sawilowsky:
%
%      d = 0.01  --> very small effect size
%      d = 0.20  --> small effect size
%      d = 0.50  --> medium effect size
%      d = 0.80  --> large effect size
%      d = 1.20  --> very large effect size
%      d = 2.00  --> huge effect size
%
%
% Ruggero G. Bettinardi (RGB)
% Cellular & System Neurobiology, CRG
% -------------------------------------------------------------------------------------------
%
% Code History:
%
% 25 Jan 2017, RGB: Function is created

if nargin < 3, testType = 'independent';
else           testType = varargin{1};
end
% basic quantities:
n1       = numel(x1);
n2       = numel(x2);
mean_x1  = nanmean(x1);
mean_x2  = nanmean(x2);
var_x1   = nanvar(x1);
var_x2   = nanvar(x2);
meanDiff = (mean_x1 - mean_x2);
% select type of test:
isIndependent = strcmp(testType, 'independent');
isPaired      = strcmp(testType, 'paired');
% compute 'd' accordingly:
if isIndependent
    
    sv1      = ((n1-1)*var_x1);
    sv2      = ((n2-1)*var_x2);
    numer    =  sv1 + sv2;
    denom    = (n1 + n2 - 2);
    pooledSD =  sqrt(numer / denom); % pooled Standard Deviation
    s        = pooledSD;             % re-name
    d        =  meanDiff / s;        % Cohen's d (for independent samples)
    
elseif isPaired
    
    haveNotSameLength = ~isequal( numel(x1), numel(x2) );
    if haveNotSameLength, error('In a paired test, x1 and x2 have to be of the same length!'), end
    
    deltas   = x1 - x2;         % differences
    sdDeltas = nanstd(deltas);  % standard deviation of the diffferences
    s        = sdDeltas;        % re-name
    d        =  meanDiff / s;   % Cohen's d (paired version)
    
end

end



function [h, p, diff, diff_null] = permtestn(a,varargin)
%   Non-parametric permutation test to compare means using
%   within-participant shuffling. Use as a paired-sample permutation test. 
%
%   H0: the two populations have equal means
%   HA: the two populations have unequal means
%
%   Usage:
%     [h p diff diff_null] = permtest(a)                          (compare to zero)
%     [h p diff diff_null] = permtest(a,b)                        (compare to a particular value, or compare the mean of two distributions)
%     [h p diff diff_null] = permtest(a,b,npermutes,pthresh,tail,dim)
%
%   Input:
%     a:          distribution 1
%     b:          (optional) distribution 2, or a single value. default: 0
%     npermutes:  (optional) the number of permutations. default: 1000
%     pthresh:    (optional) the p-threshold for significance. default: 0.05
%     tail:       (optional) test one-tailed (specify 'right' or 'left') or two-tailed (specify 'both'). default: two-tailed
%                   if there is no a priori expectation, then use 'tail' = 'both'
%                   if the a priori expectation is that a > b, then use 'tail' = 'right'
%                   if the a priori expectation is that a < b, then use 'tail' = 'left'
%     dim:        (optional) dimension across which to test. default: 1
%
%   Output:
%     h:          significance (1 or 0)
%     pval:       p-value of permutation test. Discard H0 if pval is small.
%     diff:       mean(a)-mean(b)
%     diff_null:  the permuted null distribution
%
% RL van den Brink, 2019

%% check the input

if isempty(varargin) || nargin == 1
    b = zeros(size(a));
    npermutes = 1000;
    pthresh   = 0.05;
    tail = 'both';
    dim = 1;
else    
    if nargin == 0
        error('not enough input arguments')
    elseif nargin == 2
        npermutes = 1000;
        pthresh   = 0.05;
        tail = 'both';
        b = varargin{1};
        dim = 1;
    elseif nargin == 3
        pthresh   = 0.05;
        b = varargin{1};
        npermutes = varargin{2};
        tail = 'both';
        dim = 1;
    elseif nargin == 4
        b = varargin{1};
        npermutes = varargin{2};
        pthresh = varargin{3};
        tail = 'both';
        dim = 1;
    elseif nargin == 5
        b = varargin{1};
        npermutes = varargin{2};
        pthresh = varargin{3};
        tail = varargin{4};
        dim = 1;
    elseif nargin > 6
        error('too many input arguments')
    else
        b = varargin{1};
        npermutes = varargin{2};
        pthresh = varargin{3};
        tail = varargin{4};
        dim = varargin{5};
    end
end

%get rid of possible singleton dimensions
a = squeeze(a);
b = squeeze(b);

if (length(a) ~= length(b)) && length(b) == 1
    b = zeros(size(a)) + b;
elseif (length(a) ~= length(b)) && length(b) ~= 1
    error('The data in a paired sample test must be the same size.')
end

if isempty(b); b                 = zeros(size(a)); end
if isempty(npermutes); npermutes = 1000;   end
if isempty(pthresh); pthresh     = 0.05;   end
if isempty(tail); tail           = 'both'; end
if isempty(dim); dim             = 1; end
if sum(strcmpi(tail,{'both'; 'left'; 'right'})) ~= 1; error('Unrecognized tail option'); end
if ~isnumeric(pthresh); error('Provide a numeric p threshold'); end

rv = 0;
%make sure the input distributions are row vectors if necessary
if (length(size(a)) == 2 && length(size(b)) == 2) && (any(size(b) == 1) && any(size(a) == 1))
    rv = 1; %we're testing only vectors
    if size(a,2) > size(a,1); a = a'; end
    if size(b,2) > size(b,1); b = b'; end
end


%% test

%in case of vectors:
if rv %if we're only comparing the mean of vectors
    %compute difference in mean
    diff = nanmean(a)-nanmean(b);
    %compute permuted null distribution of mean differences
    diff_null = zeros(npermutes,1);
    for permi = 1:npermutes       
        
        bnull = [a b];
        idx   = rand(size(a)) < 0.5;
        idx   = logical([idx 1-idx]);
        anull = bnull(idx);
        bnull(idx) = [];
        
        diff_null(permi) = nanmean(anull)-nanmean(bnull);
    end
    %match the empirical matrix size to the null distribution
    diffm = ones(size(diff_null))*diff;
    
%if we're comparing the mean across a particular dimension of a matrix
else      
    s = size(a); %get datasize for data, later on
    s(dim) = [];
    diff = squeeze(nanmean(a,dim)-nanmean(b,dim));
    %compute permuted null distribution of mean differences
    diff_null = zeros([npermutes prod(s)]);
    cnull = cat(dim,a,b); %concatinate across participants
    cnull = permute(cnull,[dim setdiff(1:length(size(cnull)),dim)]); %set participant dimension as the first
    for permi = 1:npermutes     
        
        idx  = rand(size(a,dim),1) < 0.5;
        idx  = logical([idx; idx-1]);
        anull = cnull;
        bnull = cnull;
        anull(~idx,:) = [];
        bnull(idx,:)  = [];
        d = nanmean(anull)-nanmean(bnull);
        
        diff_null(permi,:) = d(:);        
    end
    diff_null = reshape(diff_null,[npermutes s]);
    if isvector(diff)
        if dim == 1
            diffm = repmat( diff, [npermutes,1] );
        else
            diffm = repmat( diff', [npermutes,1] );
        end
    else
        diffm = permute( repmat(diff,[ones(1,length(size(diff))) npermutes]), [length(size(diff_null)) 1:length(size(diff))]);
    end
end

%calculate p-value
if strcmpi(tail,'both')
    p = squeeze(1-sum(abs(diffm)>abs(diff_null))/npermutes);
elseif strcmpi(tail,'right')
    p = squeeze(1-sum(diffm>diff_null)/npermutes);
elseif strcmpi(tail,'left')
    p = squeeze(1-sum(diffm<diff_null)/npermutes);
end

%compare p to the alpha level
h = p < pthresh;

end