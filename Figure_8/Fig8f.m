%% clear contents and add function folder with subfolders

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

load data_fig8f.mat

% Relevant variables are:
% accs_instr: decoding accuracy of rule in the instructed rule task, after regressing out SR-cue evoked responses
% h_instr: areas with significant decoding in the instructed rule task

%% Figure 8f

accs_instr(~logical(h_instr)) = 50; %mask out non-significant areas

gsurfl(accs_instr(1:180),[45 55],[cmap; 1 1 1]) %left hemisphere
gsurfr(accs_instr(181:end),[45 55],[cmap; 1 1 1]) %right hemisphere
