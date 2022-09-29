%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-14) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig3d.mat

% Relevant variables are:
% intrinsic_matrix_instructed: stimulus and action decoder output correlation computed on ongoing activity. This is the same is the outlined region in Figure 3c
% evoked_matrix_instructed: stimulus and action decoder output correlation computed on evoked activity.
% r_null_instr: Correlation of the evoked responses between the first and second half of data (serves as the null distribution for comparison)

%% correlate vectorized evoked and intrinsic correlation matrices

r_all = nan(size(evoked_matrix_instructed,1),1);
for subi = 1:size(evoked_matrix_instructed,1)
    a = evoked_matrix_instructed(subi,:)';
    b = intrinsic_matrix_instructed(subi,:)';    
    r_all(subi) = corr(a,b);    
end

%% plot correlation between evoked and intrinsic correlations and compare to null

figure

a = r_all; %correlation of evoked responses and iFC
b = r_null_instr; %mean across-trial consistency of correlation of evoked responses

plot(0.5,squeeze(a),'wo','MarkerFaceColor',[1 1 1]*.5)
hold on
plot(2.5,squeeze(b),'wo','MarkerFaceColor',[1 1 1]*.5)
plot([0.5 2.5],[a b],'Color',[1 1 1]*.5)
bar(nanmean([a b]),'EdgeColor','none')
wse([a b],1);
box off
set(gca,'tickdir','out')
set(gca,'fontsize',15,'xtick',[])

stats = permtestnds(a, zeros(size(a)), 10000,0.05,'both');
text(1,0.1,['p = ' num2str(stats.p)])

stats = permtestnds(b, zeros(size(b)), 10000,0.05,'both');
text(2,0.9,['p = ' num2str(stats.p)])

stats = permtestnds(a, b, 10000,0.05,'both');
title(['p = ' num2str(stats.p)])

