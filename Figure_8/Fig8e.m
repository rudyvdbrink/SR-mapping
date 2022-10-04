%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-14) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig8e.mat

% Relevant variables are:
% gr_instructed: decoding accuracy of rule in the instructed rule task, grouped by macroscale parcels of the HCP-MMP 1.0 parcellation
% gr_inferred: decoding accuracy of belief in the inferred rule task, grouped by macroscale parcels of the HCP-MMP 1.0 parcellation
% glab: labels of the parcel groups
% cmap: colors for plotting

%% Figure 8e (top)
figure

subplot(2,1,1)
hold on
x = demean(rand(size(gr_instructed,1),1) / 4); %random x-positions to reduce overlap between data points
  
for ri = 1:size(gr_instructed,2)
   %instructed
   plot(x+ri, gr_instructed(:,ri), 'wo','MarkerFaceColor',cmap(1,:))
   plot(ri, nanmean(gr_instructed(:,ri)), 'wo','MarkerFaceColor',cmap(1,:),'MarkerSize',10)   
end

xlim([0 size(gr_instructed,2)+1])
box off
set(gca,'tickdir','out', 'XTick',1:length(glab), 'XTickLabel', glab)
plot([0 size(gr_instructed,2)+1],[50 50],'k--')
title('Instructed')

%stats 
pp = nan(size(gr_instructed,2),size(gr_instructed,2));
d  = nan(size(pp));
ci = nan([size(pp),2]);
for ri = 1:size(gr_instructed,2)    
    [~, pp(ri,:)] = permtestn(gr_instructed(:,ri)-gr_instructed,0,10000); 
    a = gr_instructed(:,ri)-gr_instructed;
    for rj = 1:size(a,2)
        stats = permtestnds(a(:,rj),zeros(size(a,1),1),10000,0.05,'both');
        d(ri,rj) = stats.d;
        ci(ri,rj,:) = stats.CI;
    end
  
    ris = setdiff(1:size(gr_instructed,2),ri);
    ris(ris<ri) = [];
    for rj = 1:length(ris)
        text(ris(rj)-0.5,56-ri,['p = ' num2str(pp(ri,ris(rj)))])
    end
end

disp(['Visual (low) vs other:         p = ' num2str(pp(1,4)) ', d = ' num2str(d(1,4)) ', ci = ' num2str(ci(1,4,1)) '-' num2str(ci(1,4,2))])
disp(['Visual (low) vs somatomotor:   p = ' num2str(pp(1,3)) ', d = ' num2str(d(1,3)) ', ci = ' num2str(ci(1,3,1)) '-' num2str(ci(1,3,2))])
disp(['Visual (low) vs visual (high): p = ' num2str(pp(1,2)) ', d = ' num2str(d(1,2)) ', ci = ' num2str(ci(1,2,1)) '-' num2str(ci(1,2,2))])
disp(['Visual (high) vs other:        p = ' num2str(pp(2,4)) ', d = ' num2str(d(2,4)) ', ci = ' num2str(ci(2,4,1)) '-' num2str(ci(2,4,2))])
disp(['Visual (high) vs somatomotor:  p = ' num2str(pp(2,3)) ', d = ' num2str(d(2,3)) ', ci = ' num2str(ci(2,3,1)) '-' num2str(ci(2,3,2))])
disp(['Somatomotor vs other:          p = ' num2str(pp(3,4)) ', d = ' num2str(d(3,4)) ', ci = ' num2str(ci(3,4,1)) '-' num2str(ci(3,4,2))])

%% Figure 8e (bottom)

subplot(2,1,2)
hold on
x = demean(rand(size(gr_instructed,1),1) / 4);

for ri = 1:size(gr_instructed,2)
   %inferred
   plot(x+ri, gr_inferred(:,ri), 'wo','MarkerFaceColor',cmap(2,:))
   plot(ri, rmean(gr_inferred(:,ri)), 'wo','MarkerFaceColor',cmap(2,:),'MarkerSize',10)
end

xlim([0 size(gr_instructed,2)+1])
box off
set(gca,'tickdir','out', 'XTick',1:length(glab), 'XTickLabel', glab)
plot([0 size(gr_instructed,2)+1],[0 0],'k--')
title('Inferred')

%stats
pp = nan(size(gr_inferred,2),size(gr_inferred,2));
d  = nan(size(pp));
ci = nan([size(pp),2]);
for ri = 1:size(gr_inferred,2)    
    [~, pp(ri,:)] = permtestn(gr_inferred(:,ri)-gr_inferred,0,10000); 
    
    a = gr_inferred(:,ri)-gr_inferred;
    for rj = 1:size(a,2)
        stats = permtestnds(a(:,rj),zeros(size(a,1),1),10000,0.05,'both');
        d(ri,rj) = stats.d;
        ci(ri,rj,:) = stats.CI;
    end
  
    ris = setdiff(1:size(gr_inferred,2),ri);
    ris(ris<ri) = [];
    for rj = 1:length(ris)
        text(ris(rj)-0.5,0.3-ri/20,['p = ' num2str(pp(ri,ris(rj)))])
    end
end

disp(['Visual (low) vs other:         p = ' num2str(pp(1,4)) ', d = ' num2str(d(1,4)) ', ci = ' num2str(ci(1,4,1)) '-' num2str(ci(1,4,2))])
disp(['Visual (low) vs somatomotor:   p = ' num2str(pp(1,3)) ', d = ' num2str(d(1,3)) ', ci = ' num2str(ci(1,3,1)) '-' num2str(ci(1,3,2))])
disp(['Visual (low) vs visual (high): p = ' num2str(pp(1,2)) ', d = ' num2str(d(1,2)) ', ci = ' num2str(ci(1,2,1)) '-' num2str(ci(1,2,2))])
disp(['Visual (high) vs other:        p = ' num2str(pp(2,4)) ', d = ' num2str(d(2,4)) ', ci = ' num2str(ci(2,4,1)) '-' num2str(ci(2,4,2))])
disp(['Visual (high) vs somatomotor:  p = ' num2str(pp(2,3)) ', d = ' num2str(d(2,3)) ', ci = ' num2str(ci(2,3,1)) '-' num2str(ci(2,3,2))])
disp(['Somatomotor vs other:          p = ' num2str(pp(3,4)) ', d = ' num2str(d(3,4)) ', ci = ' num2str(ci(3,4,1)) '-' num2str(ci(3,4,2))])

