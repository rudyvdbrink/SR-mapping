%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-14) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig7c.mat

% Relevant variables are:
% conn_c: Stimulus and action decoder output correlation computed on correct trials
% conn_e: Stimulus and action decoder output correlation computed on error trials


%% Figure 7c

figure
yl = [-0.18 0.18]; %y-axis limit

%correct trials
subplot(2,3,1)
hold on

plot(0.5,squeeze(conn_c(:,1)),'wo','MarkerFaceColor',[1 1 1]*.5)
plot(2.5,squeeze(conn_c(:,2)),'wo','MarkerFaceColor',[1 1 1]*.5)
plot([0.5 2.5],conn_c,'Color',[1 1 1]*.5)
box off
set(gca,'tickdir','out','fontsize',12) 
bar(squeeze(rmean(conn_c)),'EdgeColor','none')
wse(conn_c(~isnan(sum(conn_c,2)),:),1);

%run stats and display in command window and figure
stats = permtestnds(conn_c(:,1), zeros(size(conn_c(:,1))), 10000,0.05,'both'); %rule 1
text(1,0.02,['p = ' num2str(stats.p)],'HorizontalAlignment','center')
stats = permtestnds(conn_c(:,2), zeros(size(conn_c(:,2))), 10000,0.05,'both'); %rule 2
text(2,-0.02,['p = ' num2str(stats.p)],'HorizontalAlignment','center')
stats = permtestnds(conn_c(:,1), conn_c(:,2), 10000,0.05,'both'); %rule 1 vs rule 2
title(['Correct: p = ' num2str(stats.p)])
ylim(yl)
set(gca,'ytick',yl(1):0.05:yl(2),'xtick',1:2)
xlabel('Rule')

%error trials
subplot(2,3,2)
hold on

plot(0.5,squeeze(conn_e(:,1)),'wo','MarkerFaceColor',[1 1 1]*.5)
plot(2.5,squeeze(conn_e(:,2)),'wo','MarkerFaceColor',[1 1 1]*.5)
plot([0.5 2.5],conn_e,'Color',[1 1 1]*.5)
box off
set(gca,'tickdir','out','fontsize',12) 
bar(squeeze(rmean(conn_e)),'EdgeColor','none')
wse(conn_e(~isnan(sum(conn_e,2)),:),1);

%run stats and display in command window and figure
stats = permtestnds(conn_e(:,1), zeros(size(conn_e(:,1))), 10000,0.05,'both');
text(1,0.02,['p = ' num2str(stats.p)],'HorizontalAlignment','center')
stats = permtestnds(conn_e(:,2), zeros(size(conn_e(:,2))), 10000,0.05,'both');
text(2,-0.02,['p = ' num2str(stats.p)],'HorizontalAlignment','center')
stats = permtestnds(conn_e(:,1), conn_e(:,2), 10000,0.05,'both');
title(['Error: p = ' num2str(stats.p)])
[~, ~, ~,s] = ttest(conn_e(:,1)-conn_e(:,2));
BF = t1smpbf(s.tstat,sum(~isnan(conn_e(:,1))));
text(1.5,0.05,['BF = ' num2str(BF)],'HorizontalAlignment','center')
ylim(yl)
set(gca,'ytick',yl(1):0.05:yl(2),'xtick',1:2)
xlabel('Rule')


% correct vs error trials
subplot(2,3,3)
hold on

a = conn_c-conn_e;
plot(0.5,squeeze(a(:,1)),'wo','MarkerFaceColor',[1 1 1]*.5)
plot(2.5,squeeze(a(:,2)),'wo','MarkerFaceColor',[1 1 1]*.5)
plot([0.5 2.5],a,'Color',[1 1 1]*.5)
box off
set(gca,'tickdir','out','fontsize',12) 
bar(squeeze(rmean(a)),'EdgeColor','none')
wse(a(~isnan(sum(a,2)),:),1);

%run stats and display in command window and figure
stats = permtestnds(a(:,1), zeros(size(a(:,1))), 10000,0.05,'both'); %rule 1
text(1,0.02,['p = ' num2str(stats.p)],'HorizontalAlignment','center')
stats = permtestnds(a(:,2), zeros(size(a(:,2))), 10000,0.05,'both'); %rule 2
text(2,-0.02,['p = ' num2str(stats.p)],'HorizontalAlignment','center')
stats = permtestnds(a(:,1), a(:,2), 10000,0.05,'both'); %rule 1 vs rule 2
title(['Correct vs error: p = ' num2str(stats.p)])
ylim(yl)
set(gca,'ytick',yl(1):0.05:yl(2),'xtick',1:2)
xlabel('Rule')





