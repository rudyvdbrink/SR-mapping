%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-14) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig6b.mat

% Relevant variables are:
% t: vector to keep track of time
% c: vector of time-respolved stimulus and action decoder output correlation, computed on ongoing activity. This is the same is the outlined region in Figure 5c
% rv: time-series of the belief variable
% srate: sample rate of the data
% span: width of smoothing kernel in seconds

%% plot example participant

%plotting options
alpha = 1; %transparancy of faces
yl = [-3.5 3.5];

figure
subplot(2,1,1)
hold on

plot(t, zscore(smooth(c, srate*span)))
plot(t, zscore(smooth(rv,srate*span)), 'g')
set(gca,'tickdir','out','box','off')

xlim([0 30])
ylim(yl)
xlabel('Time (min)')

%% plot patches to indicate dominant belief

subplot(2,1,2)

a = zscore(smooth(rv,srate*span));
b = double(a < 0);

segs  = bwlabeln(b); %find segments of one dominant belief
nsegs = max(segs); %the number of segments

%loop over segments and plot a patch
for segi = 1:nsegs
    s = find(segs == segi);    
    x = [s(1) s(1) s(end) s(end)];
    y = [yl(1) yl(2) yl(2) yl(1)];    
    patch(t(x),y,[0 0.4 0],'facealpha',alpha, 'facecolor',[0 0.4 0], 'edgecolor','none');
    hold on
end

xlim([0 30])
ylim(yl)
axis off
box off