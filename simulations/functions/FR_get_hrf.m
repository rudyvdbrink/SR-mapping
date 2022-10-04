function hrf = FR_get_hrf(dat,tvec,stiminfo,n)
% hrf = FR_get_hrf(data,t,stiminfo,n)
%
% Input:
%  data: Voxels x time matrix
%  t: vector of time corresponding to the columns in data
%  stiminfo: Trials x variables matrix of stimulus / response information
%            Variables: 1) onset time of stimulus
%                       2) stimulus type
%                       3) response type
%                       4) active rule
%  n: length of HRF to estimate in samples
%  dim: dimension to residualize for, corresponding to stimulus (2) or 
%       response (3)
%  hrf: hemodynamic response function
%
% Output:
%  hrf: the hemodynamic response function, estimated with deconvolution,
%  corrected to first sample and scaled to unit height

ntrials = size(stiminfo,1);

%populate the stick funtion
stickbase = zeros(size(tvec));
for ti = 1:ntrials
    %get idx of current trial
    [~, idx]       = min(abs(tvec-stiminfo(ti,1)));
    stickbase(idx) = 1;
end

s = stickbase'; %stick function
m = length(s); %length of event sequence
y = zscore(detrend(squeeze(mean(dat,1)))); %fMRI data -> voxel-average, no linear trend, and mean centered

X = zeros(m,n); %the design matrix
temp = s;
for i=1:n
    X(:,i) = temp;
    temp = [0;temp(1:end-1)];
end

PX   = pinv(X); %pseudo-inverse of design matrix
hest = PX*y'; %estimate hrf
hest = hest-hest(1); %baseline correct
hrf  = hest./max(hest); %scale to unit height

end
