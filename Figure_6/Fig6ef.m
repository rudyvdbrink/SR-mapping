%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-15) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig6ef.mat

% Relevant variables are:
% acc: cross-validated prediction accuracy of active rule from stimulus-action decoder coupling

%% plot mean cross validated prediction of model

figure

x = rand(size(acc,1),1)/4 + 1-0.125; %jitter in plot position to reduce overlap between data points
yl = [-10 10]; %y-limit for plotting

%correlation between visual and motor codes (Figure 6e)
subplot(1,3,1)
hold on
stats = permtestnds(acc(:,3), zeros(size(acc(:,3))), 10000,0.05,'both'); %connectivity 
plot(x, squeeze(nanmean(nanmean(nanmean(acc(:,3),2),3),4))  , 'wo','MarkerFaceColor',[1 1 1]/2);
plot(1, squeeze(nanmean(nanmean(nanmean(nanmean(acc(:,3),2),3),4)))  , 'wo','MarkerFaceColor','k','MarkerSize',10);
plot([0 4],[0 0 ],'k--')
title(['p = ' num2str(stats.p)])
set(gca,'fontsize',15)
set(gca,'tickdir','out','xtick',[])
ylabel('Accyracy (%)')
xlim([0 2])
ylim([-6 6])


%visual local code (Figure 6f, left)
subplot(1,3,2)
hold on
stats = permtestnds(acc(:,1), zeros(size(acc(:,1))), 10000,0.05,'both'); %visual local
plot(x, squeeze(nanmean(nanmean(nanmean(acc(:,1),2),3),4))  , 'wo','MarkerFaceColor',[1 1 1]/2);
plot(1, squeeze(nanmean(nanmean(nanmean(nanmean(acc(:,1),2),3),4)))  , 'wo','MarkerFaceColor','k','MarkerSize',10);
plot([0 4],[0 0 ],'k--')
title(['p = ' num2str(stats.p)])
set(gca,'fontsize',15)
set(gca,'tickdir','out','xtick',[])
ylabel('Accyracy (%)')
xlim([0 2])
ylim(yl)


%motor local code (Figure 6f, right)
subplot(1,3,3)
hold on
stats = permtestnds(acc(:,2), zeros(size(acc(:,2))), 10000,0.05,'both'); %motor local
plot(x, squeeze(nanmean(nanmean(nanmean(acc(:,2),2),3),4))  , 'wo','MarkerFaceColor',[1 1 1]/2);
plot(1, squeeze(nanmean(nanmean(nanmean(nanmean(acc(:,2),2),3),4)))  , 'wo','MarkerFaceColor','k','MarkerSize',10);
plot([0 4],[0 0 ],'k--')
title(['p = ' num2str(stats.p)])
set(gca,'fontsize',15)
set(gca,'tickdir','out','xtick',[])
ylabel('Accyracy (%)')
xlim([0 2])
ylim(yl)
