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

%  params: structure with parameters for the simulation
params.nsecs    = nsecs;
params.srate    = srate;
params.nvox     = nvox;
params.nl       = nl;
params.snratio  = snratio;

%% loop over repetitions

r1   = nan(nreps,1); %no noise correlations (rule 1)
r2   = nan(nreps,1); %no noise correlations (rule 2)
nr1  = nan(nreps,1); %with noise correlations (rule 1)
nr2  = nan(nreps,1); %with noise correlations (rule 2)
r1n  = nan(nreps,1); %no noise correlations, no residualization (rule 1)
r2n  = nan(nreps,1); %no noise correlations, no residualization (rule 2)
accs = nan(nreps,2); %classification accuracy in percent, for stimulus (column 1) and response (column 2)

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

    %% add in error trials
    
    pc(repi)         = randsample(pcorr(1):0.01:pcorr(2),1); %percentage correct of this participant and session
    ne(repi)         = round(ntrials * (1-pc(repi)/100)); %number of error trials    
    eidx             = randsample(1:ntrials,ne(repi)); %indices of the error trials
    stiminfo(eidx,2) = sign(stiminfo(eidx,3)) * -1; %invert response on error trials
    
    %% generate graded classifier output: including noise correlations
    
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
    
    %% now correlate graded decoder output per rule (noise correlations, with residualization)
    
    rv = conv(rv,hrf); %convolve rule vector with HRF
    rv = sign(rv(1:length(t))); %get (shifted) rule vector
    
    r1idx = rv == 1;
    r2idx = rv == -1;
    
    nr1(repi) = corr(vprob(r1idx,1),mprob(r1idx,1));
    nr2(repi) = corr(vprob(r2idx,1),mprob(r2idx,1));    
    
    %% generate graded classifier output: EXcluding noise correlations
    
    params.snratio = []; %set to empty so that no noise correlations are added
    params.nl      = 0.5; %re-set noise level

    %visual cortex
    [dat, t]           = FR_gen_data(stiminfo,params,2);           % generate data
    dat                = FR_dusample(dat,50); %downsample data, then upsample again (to simuluate low sample rate of the real fMRI data)
    es_hrf             = FR_get_hrf(dat,t,stiminfo,length(hrf));         % estimate HRF from the data in V1
    betas              = FR_get_betas(dat,stiminfo,t,es_hrf);          % run single-trial regression to get betas
    vprob              = FR_backproject(dat,betas,stiminfo,t,2,1);  % get graded classifier output in residual
    
    params.nl       = 0.25; %lower noise level for motor cortex (= higher classification accuracy)
    
    %motor cortex
    [dat, t]           = FR_gen_data(stiminfo,params,3);           % generate data
    dat                = FR_dusample(dat,50); %downsample data, then upsample again (to simuluate low sample rate of the real fMRI data)
    betas              = FR_get_betas(dat,stiminfo,t,es_hrf);          % run single-trial regression to get betas
    mprob              = FR_backproject(dat,betas,stiminfo,t,3,1);  % get graded classifier output
    
    %% now correlate graded decoder output per rule (no noise correlations, with residualization)
    
    r1(repi) = corr(vprob(r1idx,1),mprob(r1idx,1));
    r2(repi) = corr(vprob(r2idx,1),mprob(r2idx,1));   
    
    %% generate graded classifier output: EXcluding noise correlations, and EXcluding residualzation
    
    params.snratio = []; %set to empty so that no noise correlations are added
    params.nl      = 0; %re-set noise level

    %visual cortex
    [dat, t]           = FR_gen_data(stiminfo,params,2);           % generate data
    dat                = FR_dusample(dat,50); %downsample data, then upsample again (to simuluate low sample rate of the real fMRI data)
    es_hrf             = FR_get_hrf(dat,t,stiminfo,length(hrf));         % estimate HRF from the data in V1
    betas              = FR_get_betas(dat,stiminfo,t,es_hrf);          % run single-trial regression to get betas
    vprobu             = FR_backproject(dat,betas,stiminfo,t,2,0);  % get graded classifier output in NON-residualized data   
       
    %motor cortex
    [dat, t]           = FR_gen_data(stiminfo,params,3);           % generate data
    dat                = FR_dusample(dat,50); %downsample data, then upsample again (to simuluate low sample rate of the real fMRI data)
    betas              = FR_get_betas(dat,stiminfo,t,es_hrf);          % run single-trial regression to get betas
    mprobu             = FR_backproject(dat,betas,stiminfo,t,3,0);  % get graded classifier output in NON-residualized data   
    
    %% now correlate graded decoder output per rule (no noise correlations, no residualization)
    
    r1n(repi) = corr(vprobu(r1idx,1),mprobu(r1idx,1));
    r2n(repi) = corr(vprobu(r2idx,1),mprobu(r2idx,1));        
    
end

%% average across 'sessions'

nt    = cat(2,nt(1:2:end),nt(2:2:end));
accs  = nanmean(cat(3,accs(1:2:end,:),accs(2:2:end,:)),3);
r1    = nanmean(cat(2,r1(1:2:end),r1(2:2:end)),2);
r2    = nanmean(cat(2,r2(1:2:end),r2(2:2:end)),2);
nr1   = nanmean(cat(2,nr1(1:2:end),nr1(2:2:end)),2);
nr2   = nanmean(cat(2,nr2(1:2:end),nr2(2:2:end)),2);
r1n   = nanmean(cat(2,r1n(1:2:end),r1n(2:2:end)),2);
r2n   = nanmean(cat(2,r2n(1:2:end),r2n(2:2:end)),2);

%% plot classification accuracy

figure
subplot(2,3,4)
bar(mean(accs))
wsplot(accs,0)
wse(accs,1);
title('without noise correlations')
box off
set(gca,'tickdir','out','xtick',1:2,'Xticklabel',{'Visual', 'Motor'})
xlabel('ROI')
ylim([0 100])
hold on
plot([0 3],[50 50],'k--')
ylabel('Cross-validated decoding accuracy (%)')

%% plot connectivity results

%no noise correlations, no residualization
subplot(2,3,1)
bar(nanmean([r1n r2n]))
wsplot([r1n r2n],0)
wse([r1n r2n],1);
title('no residualization')
box off
set(gca,'tickdir','out')
[~, p] = permtestn(r1n,r2n,10000,0.05,'right');
text(1.5,0.5,num2str(p),'HorizontalAlignment','center','VerticalAlignment','middle');
[~, p] = permtestn([r1n -1*r2n],0,10000,0.05,'right');
text(1,0.25,num2str(p(1)),'HorizontalAlignment','center','VerticalAlignment','middle');
text(2,-0.25,num2str(p(2)),'HorizontalAlignment','center','VerticalAlignment','middle');
ylim([-1 1])
xlabel('Rule')
ylabel('Decoder output correlation')

yl = [-0.5 0.5];

%no noise correlations, with residualization
subplot(2,3,2)
bar(nanmean([r1 r2]))
wse([r1 r2],1);
wsplot([r1 r2],0)
title('without noise correlations')
set(gca,'tickdir','out')
[~, p] = permtestn(r1,r2,10000,0.05,'right');
text(1.5,0.15,num2str(p),'HorizontalAlignment','center','VerticalAlignment','middle');
[~, p] = permtestn([r1 -1*r2],0,10000,0.05,'right');
text(1,0.05,num2str(p(1)),'HorizontalAlignment','center','VerticalAlignment','middle');
text(2,-0.05,num2str(p(2)),'HorizontalAlignment','center','VerticalAlignment','middle');
ylim(yl)
xlabel('Rule')
ylabel('Decoder output correlation')

%with noise correlations, with residualization
subplot(2,3,3)
bar(nanmean([nr1 nr2]))
wsplot([nr1 nr2],0)
wse([nr1 nr2],1);
title('with noise correlations')
box off
set(gca,'tickdir','out')
[~, p] = permtestn(nr1,nr2,10000,0.05,'right');
text(1.5,0.15,num2str(p),'HorizontalAlignment','center','VerticalAlignment','middle');
[~, p] = permtestn([nr1 -1*nr2],0,10000,0.05,'right'); 
text(1,0.05,num2str(p(1)),'HorizontalAlignment','center','VerticalAlignment','middle');
text(2,-0.05,num2str(p(2)),'HorizontalAlignment','center','VerticalAlignment','middle');
ylim(yl)
xlabel('Rule')
ylabel('Decoder output correlation')
