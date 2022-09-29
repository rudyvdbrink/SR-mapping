%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-14) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig3f.mat

% Relevant variables are:
% conn_instr: Correlation of stimulus and action decoders, averaged across all visual-motor ROI pairs.
% conn_instr: Correlation of stimulus and action decoders, averaged across all auditory-motor ROI pairs. Here the stimulus decoder was trained and projected onto auditory cortex (as a control)

%% compare and plot 
figure

sub2plot = 17; %the example participant
conn = conn_instr-conn_audi_instr;

plot(0.5,squeeze(conn(:,1)),'wo','MarkerFaceColor',[1 1 1]*.5)
hold on
plot(2.5,squeeze(conn(:,2)),'wo','MarkerFaceColor',[1 1 1]*.5)
plot([0.5 2.5],conn,'Color',[1 1 1]*.5)
box off
set(gca,'tickdir','out')
bar(squeeze(rmean(conn)),'EdgeColor','none')
set(gca,'fontsize',15,'xtick',[])

plot([0.5 2.5],conn(sub2plot,:),'Color','r') %plot example subject
wse(conn(~isnan(sum(conn,2)),:),1); %error bars

stats = permtestnds(conn(:,1), zeros(size(conn(:,1))), 10000,0.05,'right');
text(1,0.02,['p = ' num2str(stats.p)],'HorizontalAlignment','center')

stats = permtestnds(conn(:,2), zeros(size(conn(:,2))), 10000,0.05,'left');
text(2,-0.02,['p = ' num2str(stats.p)],'HorizontalAlignment','center')

stats = permtestnds(conn(:,1), conn(:,2), 10000,0.05,'right');
title(['p = ' num2str(stats.p)])

set(gca,'fontsize',15,'xtick',1:2)
xlabel('Rule')


