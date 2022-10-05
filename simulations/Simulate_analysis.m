clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-18) '\functions'];
addpath(genpath(funcdir))

%% definitions

nsecs   = 600; %length of the data to generate, in seconds
srate   = 1/1.9*50; %sample rate (1 / TR * upsample factor)
nvox    = 10; %number of voxels
mtrials = 100; %the maximum number of trials
nl      = 0.5; %noise level (higher = more iid noise = lower classification accuracy)
snratio = 4; %strength of noise correlations (higher = stronger noise correlations)
nfolds  = 10; %number of cross-validation folds for classification
nreps   = 100*2; %number of repetitions of the simulation (100 participants, 2 sessions each)
pcorr   = [95 100]; %range of percentage correct trials

% params: structure with parameters for the simulation
params.nsecs    = nsecs;
params.srate    = srate;
params.nvox     = nvox;
params.nl       = nl;
params.snratio  = snratio;

%% loop over repetitions

%initialize
nr1  = nan(nreps,1); %decoder correlations (rule 1)
nr2  = nan(nreps,1); %decoder correlations (rule 2)
accs = nan(nreps,2); %classification accuracy in percent, for stimulus (column 1) and action (column 2)

pc = nan(nreps,1); %percentage correct
ne = nan(nreps,1); %number of error trials
nt = nan(nreps,1); %number of trials

for repi = 1:nreps
    
    disp(['repetition ' num2str(repi) ' / ' num2str(nreps)])
    
    %% randomly sample hrf parameters
    
    % p(1) - delay of response (relative to onset)          6
    % p(2) - delay of undershoot (relative to onset)       16
    % p(3) - dispersion of response                         1
    % p(4) - dispersion of undershoot                       1
    % p(5) - ratio of response to undershoot                6
    % p(6) - onset (seconds)                                0
    % p(7) - length of kernel (seconds)                    32
    p   = [randsample(3:0.001:6,1) randsample(7:0.001:15,1) 1 1 randsample(3:0.001:8,1) 0 32];
    hrf = spm_hrf(1/srate,p,16);
    hrf = hrf./max(hrf); %scale to max = 1   
    params.hrf      = hrf;    
    
    %% generate stimulus, response, and rule sequence
    
    ntrials  = mtrials;    
    stiminfo = nan(ntrials,4); %trials x (onset, stimulus type, response, rule)
    
    %stimulus onset times
    iti    = randsample(4:0.0001:20,ntrials); %inter-trial intervals (randomly sampled between 4 and 20 seconds)
    onsets = cumsum(iti); %stimulus onset
    stiminfo(:,1) = onsets;
    
    %stimulus type (randomly selected)
    stiminfo(:,2) = sign((rand(ntrials,1) < 0.5) - 0.5);
    
    %active rule (alternates every two trials)
    stiminfo(1:4:end,4) = 1;
    stiminfo(2:4:end,4) = 1;
    stiminfo(3:4:end,4) = -1;
    stiminfo(4:4:end,4) = -1;
    
    %response (always correct)
    stiminfo(:,3) = stiminfo(:,2).*stiminfo(:,4);
    stiminfo(stiminfo(:,1) > nsecs,:) = []; %remove trials outside of the data period
    ntrials  = size(stiminfo,1); %get number of trials
    nt(repi) = ntrials; %save number of trials

    %add in error trials    
    pc(repi)         = randsample(pcorr(1):0.01:pcorr(2),1); %percentage correct of this participant and session
    ne(repi)         = round(ntrials * (1-pc(repi)/100)); %number of error trials    
    eidx             = randsample(1:ntrials,ne(repi)); %indices of the error trials
    stiminfo(eidx,2) = sign(stiminfo(eidx,3)) * -1; %invert response on error trials
    
    %% generate data, and compute graded decoder output
    
    %Note: For simplicity, the data generated here do not contain response
    %times. So for all intents and purposes the participant presses the
    %button instantly when the stimulus is presented, and the evoked 
    %response in motor cortex is directly locked to the stimulus (rather
    %than the action). So if you use the below functions on real data, make
    %sure to correct the regresssion and residualization of action-related
    %regions for response time (i.e. lock to action instead of stimulus
    %onset).
    
    params.snratio  = snratio; %re-set so that noise correlations are added
    params.nl       = 0.5; %re-set noise level

    %visual cortex
    [dat, t, cvec]     = FR_gen_data(stiminfo,params,2);                 % generate data
    dat                = FR_dusample(dat,50); %downsample data, then upsample again (to simuluate low sample rate of the real fMRI data)
    es_hrf             = FR_get_hrf(dat,t,stiminfo,length(hrf));         % estimate HRF from the data in V1
    betas              = FR_get_betas(dat,stiminfo,t,es_hrf);            % run single-trial regression to get betas
    accs(repi,1)       = FR_run_classification(betas,stiminfo,2,nfolds); % get classification accuracy for stimulus
    vprob              = FR_backproject(dat,betas,stiminfo,t,2,1);       % get graded classifier output in residual    
    
    params.nl       = 0.25; %lower noise level for motor cortex (= higher classification accuracy)
   
    %motor cortex
    [dat, t, cvec, rv] = FR_gen_data(stiminfo,params,3,cvec);            % generate data
    dat                = FR_dusample(dat,50); %downsample data, then upsample again (to simuluate low sample rate of the real fMRI data)
    betas              = FR_get_betas(dat,stiminfo,t,es_hrf);            % run single-trial regression to get betas
    accs(repi,2)       = FR_run_classification(betas,stiminfo,3,nfolds); % get classification accuracy for response
    mprob              = FR_backproject(dat,betas,stiminfo,t,3,1);       % get graded classifier output in residual   
    
    %% correlate graded decoder output per rule 
    
    rv = conv(rv,hrf); %convolve rule vector with HRF
    rv = sign(rv(1:length(t))); %get (shifted) rule vector
    
    r1idx = rv == 1;
    r2idx = rv == -1;
    
    nr1(repi) = corr(vprob(r1idx,1),mprob(r1idx,1)); %noise correlations rule 1
    nr2(repi) = corr(vprob(r2idx,1),mprob(r2idx,1)); %noise correlations rule 2  
    
end

%% average across 'sessions'

nt    = cat(2,nt(1:2:end),nt(2:2:end));
accs  = nanmean(cat(3,accs(1:2:end,:),accs(2:2:end,:)),3);
nr1   = nanmean(cat(2,nr1(1:2:end),nr1(2:2:end)),2);
nr2   = nanmean(cat(2,nr2(1:2:end),nr2(2:2:end)),2);

%% plot classification accuracy

figure

subplot(1,2,1)
bar(mean(accs))
wsplot(accs,0)
wse(accs,1);
box off
set(gca,'tickdir','out','xtick',1:2,'Xticklabel',{'Visual', 'Motor'})
xlabel('ROI')
ylim([0 100])
hold on
plot([0 3],[50 50],'k--')
ylabel('Cross-validated decoding accuracy (%)')

%% plot correlated decoder outputs

subplot(1,2,2)
bar(nanmean([nr1 nr2]))
wsplot([nr1 nr2],0)
wse([nr1 nr2],1);
box off
set(gca,'tickdir','out')
[~, p] = permtestn(nr1,nr2,10000,0.05,'right');
text(1.5,0.15,num2str(p),'HorizontalAlignment','center','VerticalAlignment','middle');
[~, p] = permtestn([nr1 -1*nr2],0,10000,0.05,'right'); 
text(1,0.05,num2str(p(1)),'HorizontalAlignment','center','VerticalAlignment','middle');
text(2,-0.05,num2str(p(2)),'HorizontalAlignment','center','VerticalAlignment','middle');
xlabel('Rule')
ylabel('Decoder output correlation')
