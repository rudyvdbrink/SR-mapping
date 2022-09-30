%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-15) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig6gh.mat

% Relevant variables are:
% switch_locked_conn: Stimulus and action decoder output correlation computed on in windows surrounding trials locked to change points

%% Figure 6g

figure
subplot(2,2,1)
hold on

plot([-1 2],[0 0], 'k--')
plot([0.5 0.5],[-0.02 0.02], 'k--')
xlim([-1 2])

x = [-1 0 1 2];
m = nanmean(squeeze(switch_locked_conn(:,:,1)));
s = nanstd(squeeze(switch_locked_conn(:,:,1)))./sqrt(length(sublist)-2);
shadedErrorBar(x,m,s,'r');

m = nanmean(squeeze(switch_locked_conn(:,:,2)));
s = nanstd(squeeze(switch_locked_conn(:,:,2)))./sqrt(length(sublist)-2);
shadedErrorBar(x,m,s,'k');

set(gca,'xtick',-1:2,'XTickLabel',[-2 -1 1 2],'tickdir','out','fontsize',12)
xlabel('Trial relative to change point')
ylabel({'Correlation of stimulus' 'and action decoders (r)'})

%% Figure 6h

subplot(2,4,4)

b = squeeze(switch_locked_conn(:,end,1))-  squeeze(switch_locked_conn(:,end-1,1)); %trial 2 vs trial 1
a = squeeze(switch_locked_conn(:,end,2))-  squeeze(switch_locked_conn(:,end-1,2)); %trial 2 vs trial 1

a = a-b;
a(isnan(a)) = [];
x = demean(rand(size(a))/4);
plot(x+1,a,'wo','MarkerFaceColor',[1 1 1]*.5)
hold on
plot(1,mean(a),'wo','MarkerFaceColor','k','MarkerSize',10);

box off
set(gca,'tickdir','out','fontsize',12)
set(gca,'xtick',[])
xlim([0 2])
plot([0 2],[0 0], 'k--')

stats = permtestnds(a, zeros(size(a)), 10000,0.05,'both'); %visual local
title(['Trial 2 - trial 1: p = ' num2str(stats.p)])
