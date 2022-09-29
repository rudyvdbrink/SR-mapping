%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-22) 'functions'];
addpath(genpath(funcdir))

%% load the data

% load data_fig4.mat
load 'data_fig4cdefgh.mat'

% Relevant variables are:

% sublist: a list of participants corresponding to columns in the variables below
% cacc_binned_all: accuracy locked to change points, and split by rule
% cacc_binned_model_all: model accuracy locked to change points, and split by rule
% hall: The fitted H parameter, for all participants (hazard rate)
% vall: The fitted V parameter, for all participants (decision noise)
% acc: accuracy of the participants
% macc: model-predicted accuracy
% pamacc: perfect-accumulation model-predicted accuracy
% lsmacc: last-sample model-predicted accuracy
% iomacc: ideal observer model-predicted accuracy
% rv: example belief time course
% rule_example: example active rule time course
% t: time corresponding to belief time-course
% belief_split: belief split by active rule
% rule_split: consistency of belief with the active rule, split by rule

%% define example subject

sub2plot = 17;

%% Figure 4c

figure

%hazard rate
subplot(1,2,1)
plot(demean(rand(size(hall))/4),hall,'wo','MarkerFaceColor',[1 1 1]/2)
xlim([-1 1])
box off
set(gca,'tickdir','out')
hold on
plot([-0.5 0.5],[1/70 1/70],'k--') %plot generative hazard rate
plot(0,nanmean(hall),'wo','MarkerFaceColor','k','markersize',10)
ylabel('Hazard rate (H)')
set(gca,'xtick',[])

%decision noise
subplot(1,2,2)
plot(demean(rand(size(vall))/4),vall,'wo','MarkerFaceColor',[1 1 1]/2)
xlim([-1 1])
box off
set(gca,'tickdir','out')
hold on
plot(0,nanmean(vall),'wo','MarkerFaceColor','k','markersize',10)
ylabel('Decision noise (V)')
set(gca,'xtick',[])

%% Figure 4d

figure
hold on

%the data:
%rule changes from 1 to 2
x = [-2 -1 0 1];
m = nanmean(squeeze(cacc_binned_all(:,:,1)));
s = nanstd(squeeze(cacc_binned_all(:,:,1)))./sqrt(length(sublist)-2);
shadedErrorBar(x,m,s,'r');

%rule changes from 2 to 1
m = nanmean(squeeze(cacc_binned_all(:,:,2)));
s = nanstd(squeeze(cacc_binned_all(:,:,2)))./sqrt(length(sublist)-2);
shadedErrorBar(x,m,s,'k');

set(gca,'xtick',-2:1,'XTickLabel',[-2 -1 1 2],'tickdir','out','fontsize',15)
xlabel('Trial relative to change point')
ylabel('P(choice consistent with rule 1)')


%the model:
%rule changes from 1 to 2
x = [-2 -1 0 1];
m = nanmean(squeeze(cacc_binned_model_all(:,:,1)));
s = nanstd(squeeze(cacc_binned_model_all(:,:,1)))./sqrt(length(sublist)-2);
shadedErrorBar(x,m,s,'r--');

%rule changes from 2 to 1
m = nanmean(squeeze(cacc_binned_model_all(:,:,2)));
s = nanstd(squeeze(cacc_binned_model_all(:,:,2)))./sqrt(length(sublist)-2);
shadedErrorBar(x,m,s,'k--');

set(gca,'xtick',-2:1,'XTickLabel',[-2 -1 1 2],'tickdir','out','fontsize',15)
xlabel('Trial relative to change point')
ylabel('P(choice consistent with rule 1)')

%% Ffigure 4e

figure
hold on

%participant accuracy
subplot(2,1,1)
[acc,idx ] = sort(acc);
bar(acc,'EdgeColor','none','FaceColor',[1 1 1]/2)
hold on

%average model accuracy
plot((1:length(macc)),macc(idx),'wo', 'MarkerFaceColor',[1 1 1]/4)

%get all accuracy values in one matrix
d = nan(length(sublist),5);
d(:,1) = pamacc; %perfect accumulation
d(:,2) = lsmacc; %last-sample
d(:,3) = iomacc; %ideal observe
d(:,4) = acc; %participant-average
d(:,5) = macc; %model-predicted participant-average

% plot the other models
eb = bse(d,0); %error bar
bar(-1,nanmean(d(:,1)),'EdgeColor','none') %perfect accumulation
plot([-1 -1], [nanmean(d(:,1))-eb(1) nanmean(d(:,1))+eb(1)],'k','LineWidth',2)

bar(0,nanmean(d(:,2)),'EdgeColor','none') %last sample
plot([0 0], [nanmean(d(:,2))-eb(2) nanmean(d(:,2))+eb(2)],'k','LineWidth',2)

bar(19,nanmean(d(:,4)),'EdgeColor','none') %participant average

plot(19,nanmean(d(:,4)),'wo','markerfacecolor','k') %model-predicted participant average
plot([19 19], [nanmean(d(:,4))-eb(4) nanmean(d(:,4))+eb(4)],'k','LineWidth',2)

bar(20,nanmean(d(:,3)),'EdgeColor','none') %ideal
plot([20 20], [nanmean(d(:,3))-eb(3) nanmean(d(:,3))+eb(3)],'k','LineWidth',2)

xlim([-2 21])
ylim([50 90])
set(gca,'box','off','TickDir','out','xtick', [] )
ylabel('Accuracy (%)')

%stats
disp('participant average vs perfect accumulation:')
permtestnds(d(:,end),d(:,1), 10000,0.05,'both');
disp('participant average vs last sample:')
permtestnds(d(:,end),d(:,2), 10000,0.05,'both');

%% Figure 4f

alpha = 1; %transparancy of faces
yl    = [-1 1]; %y-axis limit of rule indicator

figure

%plot example belief time course
subplot(2,1,1)

hold on
plot(t, rv)
plot([t(1) t(end)],[0 0],'k--')
set(gca,'tickdir','out','box','off','fontsize',15)

xlim([0 30])
ylim(yl)
xlabel('Time (min)')

%plot patches of active rule
subplot(2,1,2)
segs  = bwlabeln(rule_example);
nsegs = max(segs);

%loop over active rule segments and plot patches
for segi = 1:nsegs
    s = find(segs == segi);    
    x = [s(1) s(1) s(end) s(end)];
    y = [yl(1) yl(2) yl(2) yl(1)];    
    patch(t(x),y,[0 0.4 0],'facealpha',alpha, 'facecolor',[0 0.4 0], 'edgecolor','none');
    hold on
end

xlim([0 30])
ylim(yl)
axis off
box off

%% Figure 4g

figure

plot(0.5,squeeze(belief_split(:,1)),'wo','MarkerFaceColor',[1 1 1]*.5)
hold on
plot(2.5,squeeze(belief_split(:,2)),'wo','MarkerFaceColor',[1 1 1]*.5)
plot([0.5 2.5],belief_split,'Color',[1 1 1]*.5)
box off
set(gca,'tickdir','out')
bar(squeeze(nanmean(belief_split)),'EdgeColor','none')
set(gca,'xtick',1:2)
xlabel('Rule')

plot([0.5 2.5],belief_split(sub2plot,:),'Color','r') %plot example subject
wse(belief_split(~isnan(sum(belief_split,2)),:),1); %error bar
ylabel('Normalized belief (L)')

%% Figure 4h
figure

plot(0.5,squeeze(rule_split(:,1)),'wo','MarkerFaceColor',[1 1 1]*.5)
hold on
plot(2.5,squeeze(rule_split(:,2)),'wo','MarkerFaceColor',[1 1 1]*.5)
plot([0.5 2.5],rule_split,'Color',[1 1 1]*.5)
box off
set(gca,'tickdir','out')
bar(squeeze(nanmean(rule_split)),'EdgeColor','none')
set(gca,'xtick',1:2)
xlabel('Rule')

plot([0.5 2.5],rule_split(sub2plot,:),'Color','r') %plot example subject
bse(rule_split(~isnan(sum(rule_split,2)),:),1);
ylabel({'Time points where' 'sign of L =/= rule (%)'} )

