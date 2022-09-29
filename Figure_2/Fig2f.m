%% clear contents and add current folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-14) 'functions'];
addpath(genpath(funcdir))

%% additionally needed: 

%https://github.com/rudyvdbrink/Surface_projection
addpath(genpath('~\Surface_projection'))

%% load the data

load data_fig2.mat

% Relevant variables are:
% g: surface for plotting
% stim_vis_acc: average classification accuracy of stimuli from visual cotex, on the surface
% stim_bg_acc: average classification accuracy of stimuli from subcortical areas
% stim_mot_acc: average classification accuracy of stimuli from motor cortex, on the surface
% act_vis_acc: average classification accuracy of action from visual cotex, on the surface
% act_bg_acc: average classification accuracy of action from subcortical areas
% act_mot_acc: average classification accuracy of action from motor cortex, on the surface

%% plot classification accuracy of stimulus decoding from visual cortex

cmap = [1 1 1; inferno;];
cortsurfl(g,stim_vis_acc,cmap,[50 73],'inflated')
view([20 -10 ])

%% plot classification accuracy of stimulus decoding from subcortex

clim = [50 65];
BG_render(stim_bg_acc,clim)

%% classification of stimuli from motor cortex

cmap = [1 1 1; inferno; 1 1 1];
cortsurfl(g,stim_mot_acc,cmap,[50 90],'inflated')
subplot(1,2,1)
view([280 40 ])




%% plot classification accuracy of action decoding from visual cortex

cmap = [1 1 1; inferno;];
cortsurfl(g,act_vis_acc,cmap,[50 73],'inflated')
view([20 -10 ])

%% plot classification accuracy of actiondecoding from subcortex

clim = [50 65];
BG_render(act_bg_acc,clim)

%% classification of action from motor cortex

cmap = [1 1 1; inferno; 1 1 1];
cortsurfl(g,act_mot_acc,cmap,[50 90],'inflated')
subplot(1,2,1)
view([280 40 ])


