function betas = FR_get_betas(dat,stiminfo,t,hrf)
% betas = FR_get_betas(dat,stiminfo,t)
% Input:
%  data: Voxels x time matrix
%  stiminfo: Trials x variables matrix of stimulus / response information
%            Variables: 1) onset time of stimulus
%                       2) stimulus type
%                       3) response type
%                       4) active rule
%  t: time vector corresponding to the data
%  dim: dimension to residualize for, corresponding to stimulus (2) or 
%       response (3)
%  hrf: hemodynamic response function
%
% Output:
%  betas: single-trial regression coefficients


%% run regression

warning('off','all')

ntrials = size(stiminfo,1);
nsamps  = length(t);

%populate the stick funtion
stickbase = zeros(size(t));
for ti = 1:ntrials
    %get idx of current trial
    [~, idx]       = min(abs(t-stiminfo(ti,1)));
    stickbase(idx) = 1;
end

%trials x voxels
betas = nan(ntrials,size(dat,1));

%run the glm
for ti = 1:ntrials
    
    %get idx of current trial
    [~, idx]   = min(abs(t-stiminfo(ti,1)));
    
    %set current trial to 1
    sticktrial      = zeros(size(stickbase));
    sticktrial(idx) = 1;
    
    %set current trial to 0 (leave the others as 1)
    stickother      = stickbase;
    stickother(idx) = 0;
    
    %convolve
    sticktrial = conv(sticktrial,hrf);
    stickother = conv(stickother,hrf);
    
    %truncate and z-score
    sticktrial = zscore(sticktrial(1:nsamps));
    stickother = zscore(stickother(1:nsamps));
    
    %this is the regression model
    x = [sticktrial' stickother'];
    
    %loop over voxels and get beta values
    for vi = 1:size(dat,1)
        y = zscore(squeeze(dat(vi,:))');
        b = regress(y,x);
        betas(ti,vi) = b(1);
    end
end