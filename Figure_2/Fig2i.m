%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-14) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig2i.mat

% Relevant variables are:
% conn_v1_4_PMd: correlation of decoder outputs from V1-V4, and PMd

%% make the plot

sub2plot = 17; %which example participant

figure
hold on

plot(0.5,squeeze(conn_v1_4_PMd(:,1)),'wo','MarkerFaceColor',[1 1 1]*.5) %rule 1
plot(2.5,squeeze(conn_v1_4_PMd(:,2)),'wo','MarkerFaceColor',[1 1 1]*.5) %rule 2
plot([0.5 2.5],conn_v1_4_PMd,'Color',[1 1 1]*.5)
bar(squeeze(rmean(conn_v1_4_PMd)),'EdgeColor','none')
wse(conn_v1_4_PMd,1);  %error bar

box off
set(gca,'tickdir','out')
set(gca,'fontsize',15,'xtick',1:2)
xlabel('Rule')

stats = permtestnds(conn_v1_4_PMd(:,1), conn_v1_4_PMd(:,2), 10000,0.05,'right');
title(['p = ' num2str(stats.p)])
plot([0.5 2.5],conn_v1_4_PMd(sub2plot,:),'Color','r') %plot example participant
