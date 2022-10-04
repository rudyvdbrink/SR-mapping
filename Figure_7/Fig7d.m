%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-14) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig7d.mat

% Relevant variables are:
% v: rank-transformed decision noise of the individual participants
% conn: rank-transformed stimulus and action decoder output correlation, difference between correct and error trials

%% compute error bar via bootstrapping

%run correlation
[r, p, ci] = permcorr(v,conn,10000,'left'); %Pearson correlation of the rank-transformed data is the same as Spearman correlation - the output r is thus Spearman's rho

%bootstrap error bar
nboots = 10000; %number of iterations for bootstrapping
cdat = [v conn]; %the data for bootstrapping

%reserve some memory
P_null = zeros(nboots,2); %the parameters of the fitted regression lines
p_n = nan(length(v),nboots); %the actual regression lines (for computing the error bar)
for bi = 1:nboots %iterate   
    cdat_null    = cdat(randsample(1:size(cdat,1),size(cdat,1),1),:); %bootstrapped data (sampled with replacement)
    P_null(bi,:) = polyfit(cdat_null(:,1),cdat_null(:,2),1); %fitted least squares regression line parameters        
    p_n(:,bi)    = getpoly(sort(v), P_null(bi,:)); %get the line at each data point
end

p1 = prctile(p_n',5);  %lower bound of CI
p2 = prctile(p_n',95); %upper bound of CI

%% Figure 7d

figure

hold on
vs = sort(v);
patch([vs; vs(end:-1:1)],[p1 p2(end:-1:1)]',[1 1 1]/2,'edgecolor','none')

plot(v,conn,'wo','MarkerFaceColor',[1 1 1]/2)
P = polyfit(v,conn,1);
hold on
polyplot(sort(v),P);
axis square
box off
set(gca,'tickdir','out')
title(['\rho = ' num2str(r) ', p = ' num2str(p)])
xlabel('Decision noise (rank)')
ylabel('\Delta correlation (rank)')
xlim([0 20])
ylim([0 20])
