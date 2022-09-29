%% clear contents and add current folder with subfolders
clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-19) 'functions'];
addpath(genpath(funcdir))


%% load the data

% Relevant variables are:
% cacc: accuracy conditioned on rule change
% acc_rule: average accuracy per rule
% rt_rule: average response time per rule

load data_fig2cde.mat

%% plot conditional accuracy 

close all

figure
subplot(2,3,1)

hold on

x = [-2 -1 0 1];
m = nanmean(squeeze(cacc(:,:,1))); %average across participants 
s = nanstd(squeeze(cacc(:,:,1)))./sqrt(N);
shadedErrorBar(x,m,s,'r');

m = nanmean(squeeze(cacc(:,:,2)));
s = nanstd(squeeze(cacc(:,:,2)))./sqrt(N);
shadedErrorBar(x,m,s,'k')

set(gca,'xtick',-2:1,'XTickLabel',[-2 -1 1 2],'tickdir','out')
xlabel('Trial relative to change point')
ylabel('P(choice consistent with rule 1)')
xlim([-2 1])

%% accuracy per rule

subplot(2,6,7)
hold on

a = squeeze(nanmean(acc_rule(:,1),2));
b = squeeze(nanmean(acc_rule(:,2),2));

plot(0.5,a,'wo','MarkerFaceColor',[1 1 1]*.5)
hold on
plot(2.5,b,'wo','MarkerFaceColor',[1 1 1]*.5)
plot([0.5 2.5],[a b],'Color',[1 1 1]*.5)
box off
set(gca,'tickdir','out')
bar(squeeze(nanmean([a b])),'EdgeColor','none')
set(gca,'xtick',[])

stats = permtestnds(a, b, 10000,0.05,'both');

a = [a b];
wse(a,1);

title(['p = ' num2str(stats.p)])
ylabel('Accuracy (%)')

%% RT per rule

subplot(2,6,9)
hold on

a = squeeze(nanmean(rt_rule(:,1),2));
b = squeeze(nanmean(rt_rule(:,2),2));

plot(0.5,a,'wo','MarkerFaceColor',[1 1 1]*.5)
hold on
plot(2.5,b,'wo','MarkerFaceColor',[1 1 1]*.5)
plot([0.5 2.5],[a b],'Color',[1 1 1]*.5)
box off
set(gca,'tickdir','out')
bar(squeeze(nanmean([a b])),'EdgeColor','none')
set(gca,'xtick',[])

stats = permtestnds(a, b, 10000,0.05,'both');

a = [a b];
wse(a,1);
title(['p = ' num2str(stats.p)])
ylabel('RT (s)')
