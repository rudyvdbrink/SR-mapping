%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-14) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig8g.mat

% Relevant variables are:
% rc_instr: correlation between local rule code and SR-decoder coupling, in the instructed rule task
% rc_inf: correlation between local belief code and SR-decoder coupling, in the inferred rule task
% blab: ROI labels
% cmap: colors for plotting

%% Figure 8g

figure
hold on

x = demean(rand(size(rc_instr,1),1) / 4); %random x-positions to reduce overlap between data points

%plot
for ri = 1:size(rc_instr,2)
   %instructed
   plot(x+ri-0.2, rc_instr(:,ri), 'wo','MarkerFaceColor',cmap(1,:))
   plot(ri-0.2, rmean(rc_instr(:,ri)), 'wo','MarkerFaceColor',cmap(1,:),'MarkerSize',10)
   
   %inferred
   plot(x+ri+0.2, rc_inf(:,ri), 'wo','MarkerFaceColor',cmap(2,:))
   plot(ri+0.2, rmean(rc_inf(:,ri)), 'wo','MarkerFaceColor',cmap(2,:),'MarkerSize',10)
end

xlim([0 size(rc_instr,2)+1])
box off
set(gca,'tickdir','out', 'XTick',1:length(blab), 'XTickLabel', blab)
plot([0 size(rc_instr,2)+1],[0 0],'k--')
ylim([-0.025 0.02])

%stats (instructed)
d  = nan(size(rc_instr,2),3);
p  = nan(size(rc_instr,2),3);
ci = nan(size(rc_instr,2),3,2);
for ri = 1:size(rc_instr,2)
   text(ri-0.2,0,['p = ' num2str(p(ri))])   
   stats      = permtestnds(rc_instr(:,ri),zeros(size(rc_instr,1),1),10000,0.05,'both');
   d(ri,1)    = stats.d;
   p(ri,1)    = stats.p;
   ci(ri,1,:) = stats.CI;   
end

%stats (inferred)
for ri = 1:size(rc_instr,2)
    text(ri+0.2,0.01,['p = ' num2str(p(ri))])
    stats      = permtestnds(rc_inf(:,ri),zeros(size(rc_inf,1),1),10000,0.05,'both');
    d(ri,2)    = stats.d;
    p(ri,2)    = stats.p;
    ci(ri,2,:) = stats.CI;
end

%stats (instructed vs inferred)
for ri = 1:size(rc_instr,2)
   text(ri,0.02,['p = ' num2str(p(ri))])
   stats      = permtestnds(rc_instr(:,ri) - rc_inf(:,ri),zeros(size(rc_inf,1),1),10000,0.05,'both');
   d(ri,3)    = stats.d;
   p(ri,3)    = stats.p;
   ci(ri,3,:) = stats.CI;
end
