%% clear contents and add function folder with subfolders

clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-15) 'functions'];
addpath(genpath(funcdir))

%% load the data

load data_fig7ab.mat

% Relevant variables are:
% t: vector to keep track of time
% sublist: a list of participants corresponding to rows in the variables below
% nsecs: positive range of the data
% cols: RGB colors for plotting (just red and green)
% v1v4: classification accuracy of stimuli from evoked responses in areas V1-V4, separately for correct and error trials
% pmd: classification accuracy of stimuli from evoked responses in area PMd, separately for correct and error trials

%% Figure 7a

figure
subplot(2,1,1)
hold on
plot([-nsecs nsecs],[50 50],'k--')
plot([0 0],[40 80],'k--')

%plot data
for ci = 1:2
    m = squeeze(nanmean(v1v4(:,:,ci)));
    s = squeeze(nanstd(v1v4(:,:,ci))) ./ sqrt(length(sublist)-2);
    shadedErrorBar(t,m,s,{'Color',cols(ci,:),'LineWidth',1});
end

%run statistics
[~, p] = permtestn(cat(3,v1v4-50,v1v4(:,:,1)-v1v4(:,:,2)),0,10000);
hh = fdr(p,0.05); %correct for multiple comparisons

%plot statistics
for ci = 1:3
    h = squeeze(hh(:,ci));
    if sum(h) > 0
        if ci == 1
            plot(t(logical(h)),50,'g.') %correct
        elseif ci == 2
            plot(t(logical(h)),52,'r.') %error
        elseif ci == 3
            plot(t(logical(h)),54,'k.') %correct vs error
        end
    end    
end

title('V1-V4')
xlim([-3 nsecs])
set(gca,'XTick',-6:2:6,'TickDir','out');
ylim([40 80])
xlabel('Peri-stimulus time (s)')
ylabel({'Decoding ' 'accuracy (%)'})
xlim([-3 nsecs])

%% Figure 7b

subplot(2,1,2)
hold on
plot([-nsecs nsecs],[50 50],'k--')
plot([0 0],[40 100],'k--')

%plot data
for ci = 1:2
    m = squeeze(nanmean(pmd(:,:,ci)));
    s = squeeze(nanstd(pmd(:,:,ci))) ./ sqrt(length(sublist)-2);
    shadedErrorBar(t,m,s,{'Color',cols(ci,:),'LineWidth',1});
end

%run statistics
[~, p] = permtestn(cat(3,pmd-50,pmd(:,:,1)-pmd(:,:,2)),0,10000);
hh = fdr(p,0.05); %correct for multiple comparisons

%plot statistics
for ci = 1:3
    h = squeeze(hh(:,ci));
    if sum(h) > 0
        if ci == 1
            plot(t(logical(h)),50,'g.') %correct
        elseif ci == 2
            plot(t(logical(h)),52,'r.') %error
        elseif ci == 3
            plot(t(logical(h)),54,'k.') %correct vs error
        end
    end    
end

title('PMd')
xlim([-3 nsecs])
set(gca,'XTick',-6:2:6,'TickDir','out');
ylim([40 100])
xlabel('Peri-response time (s)')
ylabel({'Decoding ' 'accuracy (%)'})
xlim([-3 nsecs])

