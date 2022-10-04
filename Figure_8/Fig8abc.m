%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-16) 'functions'];
addpath(genpath(funcdir))

%% additionally needed: 

%https://github.com/rudyvdbrink/Surface_projection
addpath(genpath('~\Surface_projection'))

%% load the data

load data_fig8abc.mat

% Relevant variables are:
% accs_instr: decoding accuracy of rule in the instructed rule task
% accs_inf: decoding accuracy of blief in the inferred rule task
% h_instr: areas with significant decoding in the instructed rule task
% h_infr: areas with significant decoding in the inferred rule task
% cmap: a red-blue colormap

%% Figure 8a

gsurfl(accs_instr(1:180),[45 55],[cmap; 1 1 1]) %left hemisphere
gsurfr(accs_instr(181:end),[45 55],[cmap; 1 1 1]) %right hemisphere

%% Figure 8b

gsurfl(accs_inf(1:180),[-0.2 0.2],[cmap; 1 1 1]) %left hemisphere
gsurfr(accs_inf(181:end),[-0.2 0.2],[cmap; 1 1 1]) %right hemisphere

%% Figure 8c

cmap = [0 0.5 0.8; %instructed (blue)
        0 0.8 0.5; %inferred (green)
        0.8 0.5 0; %conjunction (orange)
        ];

b = zeros(size(accs_instr));
b(logical(h_instr))                  = 1; %instructed
b(logical(h_inf))                    = 2; %inferred
b(logical(h_instr) & logical(h_inf)) = 3; %conjunction

gsurfl(b(1:180),[0 4],[1 1 1; cmap; 1 1 1])
gsurfr(b(181:end),[0 4],[1 1 1; cmap; 1 1 1])