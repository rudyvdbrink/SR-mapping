%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-17) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig3abce.mat

% Relevant variables are:
% conn: correlation of decoder outputs between all ROI pairs
% modz: vector to keep track of the visual / motor parts of the connectivity matrix
% sublist: list of participants
% vlab: visual cortex ROI labels
% mlab: motor ROI labels
% lab: all ROI labels

%% plot connectivity matrices

sub2plot = 17; %which one is the example participant

load cmap

figure
subplot(2,3,1)
imagesc(squeeze(rmean(conn(:,1,:,:))))
axis square
box off
colormap(cmap)
colorbar
set(gca,'clim',[-0.1 0.1]*1,'xtick',[],'ytick',1:length(lab),'YTickLabel',lab,'tickdir','out')

subplot(2,3,2)
imagesc(squeeze(rmean(conn(:,2,:,:))))
axis square
box off
colormap(cmap)
colorbar
set(gca,'clim',[-0.1 0.1]*1,'xtick',[],'ytick',1:length(lab),'YTickLabel',lab,'tickdir','out')

subplot(2,3,3)
imagesc(squeeze(rmean(conn(:,1,:,:)))-squeeze(rmean(conn(:,2,:,:))))
axis square
box off
colormap(cmap)
colorbar
set(gca,'clim',[-0.1 0.1]/2,'xtick',[],'ytick',1:length(lab),'YTickLabel',lab,'tickdir','out')

%% test (all visual-motor roi pairs)

modz = [ones(length(vlab),1); ones(length(mlab),1)*2];

conn2 = conn;
modz2 = modz;

clear d
for subi = 1:length(sublist)
    for condi = 1:2
        d(subi,condi,:,:) = module_mean(squeeze(conn2(subi,condi,:,:)),modz2,1,0);        
    end
    d(subi,condi+1,:,:) = module_mean( squeeze(conn2(subi,1,:,:)) -  squeeze(conn2(subi,2,:,:)) ,modz2,1,0);
end


a = squeeze(d(:,1:2,2,1));
subplot(2,6,7)
plot(0.5,squeeze(a(:,1)),'wo','MarkerFaceColor',[1 1 1]*.5)
hold on
plot(2.5,squeeze(a(:,2)),'wo','MarkerFaceColor',[1 1 1]*.5)
plot([0.5 2.5],a,'Color',[1 1 1]*.5)
box off
set(gca,'tickdir','out')
bar(squeeze(rmean(a)),'EdgeColor','none')
set(gca,'fontsize',15,'xtick',[])

plot([0.5 2.5],a(sub2plot,:),'Color','r') %plot example subject
wse(a(~isnan(sum(a,2)),:),1); %error bar

stats = permtestnds(a(:,1), zeros(size(a(:,1))), 10000,0.05,'right');
text(1,0.02,['p = ' num2str(stats.p)],'HorizontalAlignment','center')

stats = permtestnds(a(:,2), zeros(size(a(:,2))), 10000,0.05,'left');
text(2,-0.02,['p = ' num2str(stats.p)],'HorizontalAlignment','center')

stats = permtestnds(a(:,1), a(:,2), 10000,0.05,'right');
title(['p = ' num2str(stats.p)])


%% test (within-visual)

a = conn;
for subi = 1:length(sublist)
    for condi = 1:2
        b = squeeze(conn(subi,condi,:,:));
        b(logical(eye(size(b)))) = nan;
        a(subi,condi,:,:) = b;
    end
end
a = squeeze(nanmean(nanmean(a(:,:,1:length(vlab),1:length(vlab)),3),4));


subplot(2,6,11)
plot(0.5,squeeze(a(:,1)),'wo','MarkerFaceColor',[1 1 1]*.5)
hold on
plot(2.5,squeeze(a(:,2)),'wo','MarkerFaceColor',[1 1 1]*.5)
plot([0.5 2.5],a,'Color',[1 1 1]*.5)
box off
set(gca,'tickdir','out')
bar(squeeze(rmean(a)),'EdgeColor','none')
set(gca,'fontsize',15,'xtick',[])

plot([0.5 2.5],a(sub2plot,:),'Color','r') %plot example subject
wse(a(~isnan(sum(a,2)),:),1);

stats = permtestnds(a(:,1), zeros(size(a(:,1))), 10000,0.05,'right');
text(1,0.12,['p = ' num2str(stats.p)],'HorizontalAlignment','center')

stats = permtestnds(a(:,2), zeros(size(a(:,2))), 10000,0.05,'right');
text(2,0.12,['p = ' num2str(stats.p)],'HorizontalAlignment','center')

stats = permtestnds(a(:,1), a(:,2), 10000,0.05,'right');
title(['p = ' num2str(stats.p)])

%% test (within-motor: all)

a = conn;
for subi = 1:length(sublist)
    for condi = 1:2
        b = squeeze(conn(subi,condi,:,:));
        b(logical(eye(size(b)))) = nan;
        a(subi,condi,:,:) = b;
    end
end
a = squeeze(nanmean(nanmean(a(:,:,length(vlab)+1:end,length(vlab)+1:end),3),4));


subplot(2,6,12)
plot(0.5,squeeze(a(:,1)),'wo','MarkerFaceColor',[1 1 1]*.5)
hold on
plot(2.5,squeeze(a(:,2)),'wo','MarkerFaceColor',[1 1 1]*.5)
plot([0.5 2.5],a,'Color',[1 1 1]*.5)
box off
set(gca,'tickdir','out')
bar(squeeze(rmean(a)),'EdgeColor','none')
set(gca,'fontsize',15,'xtick',[])

plot([0.5 2.5],a(sub2plot,:),'Color','r') %plot example subject
wse(a(~isnan(sum(a,2)),:),1);

stats = permtestnds(a(:,1), zeros(size(a(:,1))), 10000,0.05,'right');
text(1,0.16,['p = ' num2str(stats.p)],'HorizontalAlignment','center')

stats = permtestnds(a(:,2), zeros(size(a(:,2))), 10000,0.05,'right');
text(2,0.16,['p = ' num2str(stats.p)],'HorizontalAlignment','center')

stats = permtestnds(a(:,1), a(:,2), 10000,0.05,'both');
title(['p = ' num2str(stats.p)])

