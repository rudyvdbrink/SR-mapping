%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-17) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig9abcd.mat

% Relevant variables are:
% conn: correlation of decoder outputs between all ROI pairs
% modz: vector to keep track of the visual / motor parts of the connectivity matrix
% sublist: list of participants
% vlab: visual cortex ROI labels
% mlab: motor ROI labels
% lab: all ROI labels
% cmap: a red-blue colormap

%% Figure 9a-c

figure
subplot(2,3,1)
imagesc(squeeze(rmean(conn(:,1,:,:))))
axis square
box off
colormap(cmap)
colorbar
set(gca,'clim',[-0.1 0.1]*10,'xtick',[],'ytick',1:length(lab),'YTickLabel',lab,'tickdir','out')

subplot(2,3,2)
imagesc(squeeze(rmean(conn(:,2,:,:))))
axis square
box off
colormap(cmap)
colorbar
set(gca,'clim',[-0.1 0.1]*10,'xtick',[],'ytick',1:length(lab),'YTickLabel',lab,'tickdir','out')

subplot(2,3,3)
imagesc(squeeze(rmean(conn(:,1,:,:)))-squeeze(rmean(conn(:,2,:,:))))
axis square
box off
colormap(cmap)
colorbar
set(gca,'clim',[-0.5 0.5],'xtick',[],'ytick',1:length(lab),'YTickLabel',lab,'tickdir','out')

%% Figure 9d

%calculate average inter-regional correlations in the visual-action ROI pairs
d = nan(length(sublist),2,2,2);
for subi = 1:length(sublist)
    for condi = 1:2
        d(subi,condi,:,:) = module_mean(squeeze(conn(subi,condi,:,:)),modz,1,0);        
    end
end

a = squeeze(d(:,1:2,2,1)); 
subplot(2,6,7)
plot(0.5,squeeze(a(:,1)),'wo','MarkerFaceColor',[1 1 1]*.5)
hold on
plot(2.5,squeeze(a(:,2)),'wo','MarkerFaceColor',[1 1 1]*.5)
plot([0.5 2.5],a,'Color',[1 1 1]*.5)
box off
set(gca,'tickdir','out')
bar(squeeze(nanmean(a)),'EdgeColor','none')
set(gca,'xtick',1:2)
xlabel('Rule')
wse(a(~isnan(sum(a,2)),:),1); %error bars
ylim([0 0.8])

%stats
stats = permtestnds(a(:,1), zeros(size(a(:,1))), 10000,0.05,'both'); %rule 1
text(1,0.2,['p = ' num2str(stats.p)],'HorizontalAlignment','center')
stats = permtestnds(a(:,2), zeros(size(a(:,2))), 10000,0.05,'both'); %rule 2
text(2,0.2,['p = ' num2str(stats.p)],'HorizontalAlignment','center')
stats = permtestnds(a(:,1), a(:,2),              10000,0.05,'both'); %rule 1 vs rule 2 
title(['p = ' num2str(stats.p)])

