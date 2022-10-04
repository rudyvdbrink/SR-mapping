function [prob, dat] = FR_backproject(dat,betas,stiminfo,t,dim,res)
% [prob, data] = FR_backproject(data,betas,stiminfo,t,dim,res)
%
% Input:
%  data: Voxels x time matrix
%  betas: single-trial regression coefficients
%  stiminfo: Trials x variables matrix of stimulus / response information
%            Variables: 1) onset time of stimulus
%                       2) stimulus type
%                       3) response type
%                       4) active rule
%  t: time vector corresponding to the data
%  dim: dimension to residualize for, corresponding to stimulus (2) or 
%       response (3)
%  res: residualize (1) for evoked responses, or not (0)
%
% Output:
%   prob: Time x type matrix of graded classifier output 
%   data: The data, residualized for evoked responses if this option is
%   selected

 %% balance conditions
 
cis           = unique(stiminfo(:,dim)); %unique stimulus / response types
stiminfo(:,2) = stiminfo(:,dim);

if sum(stiminfo(:,2)==cis(2)) > sum(stiminfo(:,2)==cis(1))
    n = sum(stiminfo(:,2)==cis(2)) - sum(stiminfo(:,2)==cis(1));
    %sample n from condition 1
    idx = find(stiminfo(:,2) == cis(1));
    idx = randsample(idx,n,1);
elseif  sum(stiminfo(:,2)==cis(2)) < sum(stiminfo(:,2)==cis(1))
    n = sum(stiminfo(:,2)==cis(1)) - sum(stiminfo(:,2)==cis(2));
    %sample n from condition 2
    idx = find(stiminfo(:,2) == cis(2));
    idx = randsample(idx,n,1);
end

if sum(stiminfo(:,2)==cis(1)) ~= sum(stiminfo(:,2)==cis(2))
    betas = cat(1,betas,betas(idx,:));
    stiminfo = cat(1,stiminfo,stiminfo(idx,:));
end

%% train SVM on regression coefficients

svmmodel = fitcsvm(zscore(betas),stiminfo(:,2));
            
%% remove evoked activity with deconvolution (if requested)

if res
    ntrials = size(stiminfo,1); %number of trials
    
    %populate the stick funtion
    covarmodel = zeros(length(t),2);
    for ti = 1:ntrials
        %get idx of current trial
        [~, idx]       = min(abs(t-stiminfo(ti,1)));
        
        if stiminfo(ti,2) == cis(1)
            covarmodel(idx,1) = 1;
        elseif stiminfo(ti,2) == cis(2)
            covarmodel(idx,2) = 1;
        end
    end
    
    %make design matrix
    XX = [];
    for ci = 1:2
        s = covarmodel(:,ci); %stick function
        m = length(s); %length of event sequence
        n = 843; %length of segment (corresponds to the length of the HRF)
        
        X = zeros(m,n); %the design matrix
        temp = s;
        for i=1:n
            X(:,i) = temp;
            temp = [0; temp(1:end-1)];
        end
        
        XX = cat(2,XX,X);
    end
    
    %remove from data
    PX = pinv(XX);
    for vi = 1:size(dat,1)
        y = zscore(detrend(dat(vi,:))); %fMRI data -> no linear trend and mean centered
        es = PX'*(XX'*y'); %explained signal
        dat(vi,:) = dat(vi,:) - es'; %residual
    end
end

%% back project SVM

[~,prob] = predict(svmmodel,dat');

end