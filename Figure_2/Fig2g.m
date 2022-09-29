%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-14) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig2g.mat

% Relevant variables are:
% example_conn: example connectivity between selective voxels in V1-V4 and PMd

%% make the plot

figure

yl = [-0.2 0.2];
conn = squeeze(nanmean(nanmean(example_conn)));

subplot(2,2,1)
hold on

%Rule 1
a = squeeze(example_conn(:,:,1,1)); %left M1, rule 1, horizontal
b = squeeze(example_conn(:,:,3,1)); %left M1, rule 1, vertical
plot([1-0.1 2+0.1],[a(:) b(:)],'bo-')

a = squeeze(example_conn(:,:,2,1)); %right M1, rule 1, horizontal
b = squeeze(example_conn(:,:,4,1)); %right M1, rule 1, vertical
plot([1-0.2 2+0.2],[a(:) b(:)],'ro-')

plot([squeeze(conn(1,1)) squeeze(conn(3,1))],'o-','linewidth',3) %left M1, horizontal to vertical
plot([squeeze(conn(2,1)) squeeze(conn(4,1))],'s-','linewidth',3) %right M1, horizontal to vertical

plot([0 3],[0 0],'k--')

xlabel('Orientation')
xlim([0 3])
set(gca,'xtick',1:2,'XTickLabel',{'H' 'V'})
title('Rule 1')
ylim(yl)
box off
set(gca,'tickdir','out','ytick',-0.3:0.1:0.3)


subplot(2,2,2)
hold on


%Rule 2
a = squeeze(example_conn(:,:,1,2)); %left M1, rule 2, horizontal
b = squeeze(example_conn(:,:,3,2)); %left M1, rule 2, vertical
plot([1-0.1 2+0.1],[a(:) b(:)],'bo-')

a = squeeze(example_conn(:,:,2,2)); %right M1, rule 2, horizontal
b = squeeze(example_conn(:,:,4,2)); %right M1, rule 2, vertical
plot([1-0.2 2+0.2],[a(:) b(:)],'ro-')

plot([squeeze(conn(1,2)) squeeze(conn(3,2))],'o-','linewidth',3) %left M1, horizontal to vertical
plot([squeeze(conn(2,2)) squeeze(conn(4,2))],'s-','linewidth',3) %right M1, horizontal to vertical

plot([0 3],[0 0],'k--')

xlabel('Orientation')
xlim([0 3])
set(gca,'xtick',1:2,'XTickLabel',{'H' 'V'})
title('Rule 2')
ylim(yl)
box off
set(gca,'tickdir','out','ytick',-0.3:0.1:0.3)

