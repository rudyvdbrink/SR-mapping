function [dat, t, noise, rv] = FR_gen_data(stiminfo,params,dim,noise)
% [dat, t, noise] = FR_gen_data(stiminfo,params,dim,noise)
%
% Input:
%  stiminfo: Trials x variables matrix of stimulus / response information
%            Variables: 1) onset time of stimulus
%                       2) stimulus type
%                       3) response type
%                       4) active rule
%  params: structure with parameters for the simulation
%       params.nsecs: length of the data in seconds
%       params.srate: data sample rate
%       params.nvox: number of voxels
%       params.nl: noise level (0 to infinity, where higher = more noise)
%       params.hrf: hemodynamic response function
%       params.snratio: determines the ratio between signal correlations
%                       and noise correlations, where higher values mean
%                       stronger noise correlations. if the input argument
%                       noise (see below) is supplied, this parameter does
%                       nothing
%  dim: dimension to residualize for, corresponding to stimulus (2) or 
%       response (3)
%  noise: vector of intrinsic fluctuations of discriminant pattern
%       (optional)
%
% Output:
%   data: The data, a voxel x time matrix
%   t: time vector corresponding to the data
%   noise: vector of intrinsic fluctuations of discriminant pattern (only
%         generated de novo if not provided as input to the function)
%   rv: vector indicating active rule at any given time

%% get settings

warning('off','all')

nsecs   = params.nsecs; % length of the data in seconds
srate   = params.srate; % data sample rate
nvox    = params.nvox; % number of voxels
nl      = params.nl; % noise level (0 to infinity, where higher = more noise)
hrf     = params.hrf;
snratio = params.snratio; %determines the ratio between signal correlations and noise correlations

ntrials = size(stiminfo,1); %number of trials
nsamps  = round(nsecs*srate); %number of samples in the data
t       = linspace(0,nsecs,nsamps); %time vector

%do we want to add in fluctuations of the discriminant pattern?
%yes:
% if noise is supplied
% if noise is not supplied, but snratio is supplied
%
%no:
% noise is not supplied, and snratio is not supplied either
if ~exist('noise','var')
    noise = [];
end

if isempty(noise)
    noisecorr = 0;
else
    noisecorr = 1;    
end

if ~isempty(snratio)
    noisecorr = 1;
else
    snratio = 5;
end

if snratio > 10 || snratio < 0
    error('Parameter snratio should be between 0 and 10')
end

%% make vector that keeps track of active rule

rv = zeros(size(t)); %rule vector (point indices)
rj = zeros(size(t)); %rule vector (block vector)
for si = 2:ntrials
    d = (stiminfo(si,1)-stiminfo(si-1,1))/2;
    [~, idx] = min(abs(t-(stiminfo(si,1)-d)));
    rv(idx)  = stiminfo(si,4);
end
c = 0;
for ti = 3:length(rv)
    if rv(ti) ~= rv(ti-1) && rv(ti) ~= 0
        c = rv(ti);
    end
    rj(ti) = c;
end
rj(rj == 0) = 1;
cues        = rv; %these are the points in between trials
cues(1)     = 1;  %set the start of the run as a point for an SR-cue
rv = rj;

%make a stick function that simulates the SR-cue, so that we can model its
%evoked response
cidx = find(cues);
cues(cidx(2:2:end)) = 0; %SR-cues are only presented every other trial, so discard half of them

%% generate intrinsic pattern fluctuation (if requested)

if noisecorr %the noise should be correlated to that of another region    
    %if there is no vector for the noise correlations yet, make a new one
    if isempty(noise)
        noise = demean(rand(1,length(t))) * nl;

    %otherwise, corrupt the supplied version with iid noise
    else        
        
        %make irr noise that is uncorrelated to our original noise
        mnoise = demean(rand(1,length(t))) * (10-snratio);        
        r = corr(noise',mnoise');

        while r < -0.0001 && r > 0.0001
            mnoise = demean(rand(1,length(t))) * (10-snratio);
            r = corr(noise',mnoise');
        end        
        
        %scale
        noise  = noise + mnoise;
        noise  = demean(linmap(noise,[min(noise) max(noise)],[-.5 .5] * nl));

        %flip sign of correlation (pattern) by rule
        noise(rj==-1) = noise(rj==-1) * -1;
    end
    
else %the noise should not be correlated to that of another region  
    noise = demean(rand(1,length(t))) * nl;
end
    
    
%% generate the data 


patterns = demean(rand(nvox,1)); %relative preference of stimulus / response 1 over -1, for each voxel
dat      = nan(nvox,nsamps); %the data, size: voxes x time

%loop over voxels
for vi = 1:nvox
    stickbase = zeros(1,nsamps);
    
    %loop over trials
    for ti = 1:ntrials        
        %get weight of the current trial, for this voxel (preferred stimuli
        %are upweighted relative to 1, non-preferred stimuli are
        %down-weighted)
        w = 1 + (patterns(vi)*stiminfo(ti,dim));
        
        %get index of current trial and enter into data vector
        [~,idx] = min(abs(t-stiminfo(ti,1)));
        stickbase(idx) = w;
    end
       
    %add in intrinsic fluctuation of pattern
    stickbase = stickbase + noise * patterns(vi);
    
    %add in SR-cues
    stickbase = stickbase + abs(cues);
    
    %convolve with HRF
    stickbase = conv(stickbase,hrf);
    
    %enter into data matrix
    dat(vi,:) = zscore(stickbase(:,1:nsamps));
end



end


%% supporting functions

%function for range mapping
function v = linmap(v,oldrange,newrange)
%linmap:  Linearly scale one range vector onto another range.
%   
%   v = LINMAP(v,oldrange,newrange) linearly stretches vector range such
%   that its min becomes newrange(1) and its max becomes newrange(2). Input
%   range should be a single row or column vector, and input newrange
%   should be a single row or column vector of length 2. Oldrange should
%   also be a single row or column vector of length 2 and specifies the min
%   and max values in v that are mapped onto the newrange. Values in v
%   outside of oldrange get set to the min or max. 

%linearly compress / stretch values to the new range
v  = ( (v - oldrange(1)) ./ (oldrange(2) - oldrange(1)) ) * (newrange(end) - newrange(1)) + newrange(1);
%set values that are outside of the new range to the min and max
v(v < newrange(1)) = newrange(1);
v(v > newrange(2)) = newrange(2);

end

%function for removing the mean
function [y, mu] = demean(x,dim)
%demean: De-mean a variable.
%   
%   y = DEMEAN(x) subtracts the mean of variable x from the elements in x.
%
%   [y, mu] = DEMEAN(x,dim) subtracts the mean along dimension dim and
%   returns the original mean mu. The default dimension that DEMEAN uses is
%   the first non-singleton dimension

% Check the input
if nargin > 2
    error('Im sorry Dave, but I cant let you do that. Provide two inputs max.')
end

% Remove mean
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
