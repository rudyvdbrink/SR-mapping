%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-14) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig6a.mat

% Relevant variables are:
% residual_conn_instructed: Stimulus and action decoder output correlation computed on ongoing activity. This is the same is the outlined region in Figure 3c
% residual_conn_inferred: Stimulus and action decoder output correlation computed on ongoing activity. This is the same is the outlined region in Figure 5c

%% Run and plot correlation of residual connectivity between instructed and inferred
npermutes = 10000; %how many permutation iterations
prctile2plot = 95; %what confidence interval to plot around mean correlation

figure
hold on

[r, p, ci, r_null] = permcorr(residual_conn_instructed(:),residual_conn_inferred(:),npermutes);
bar(1,r,'EdgeColor','none')
plot([1 1],[prctile(r_null,100-prctile2plot) prctile(r_null,prctile2plot)]+r,'k-', 'linewidth',2)
text(1,0.2,['p = ' num2str(p)])

set(gca,'tickdir','out','xtick',[]);
box off
