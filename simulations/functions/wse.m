function sem = wse(data,plotinfig)
% sem = WSE(data,plotinfig)
%
% compute and / or plot within-subject error bars
%
% input matrix data needs to be two-dimensional with the first dimension 
% being participants, and the seconds being conditions

if ~exist('plotinfig','var')
    plotinfig = 0;
end

nsubs = size(data,1);
ncondis = size(data,2);


%subtract across-condition mean from each participant and get SEM
nmdata = data-nanmean(data,2);
sem = nanstd(nmdata,1)./sqrt(nsubs);

if plotinfig
    hold on    
    plot([1:ncondis; 1:ncondis] , [nanmean(data,1)-sem; nanmean(data,1)+sem],'k','LineWidth',2)
end
    
    
