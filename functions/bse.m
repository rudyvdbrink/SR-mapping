function sem = bse(data,plotinfig)
% sem = BSE(data,plotinfig)
%
% compute and / or plot between-subject error bars
%
% input matrix data needs to be two-dimensional with the first dimension 
% being participants, and the seconds being conditions

if ~exist('plotinfig','var')
    plotinfig = 0;
end

nsubs = size(data,1);
ncondis = size(data,2);


%get SEM
sem = nanstd(data,1)./sqrt(nsubs);

if plotinfig
    hold on    
    plot([1:ncondis; 1:ncondis] , [nanmean(data,1)-sem; nanmean(data,1)+sem],'k','LineWidth',2)
end
    
    
