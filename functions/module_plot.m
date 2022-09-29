function module_plot(modz,center,plotopts)
% MODULE_PLOT outlines modules in a plot.
%
%   Usage:
%      module_plot(modz)
%      module_plot(modz,center,plotopts)
%
%   Input:
%     modz:       vector of module numbers, with one numeric value per
%                 index that indicates what module each index belongs to
%     center:     (optional) plot along the diagonal only (1) or not (0, 
%                 deault) 
%     plotopts:   (optional) cell array with plot options 
%                 (e.g. {'k--','linewidth',2}, or {'color',[0.5 0.5 0]})
%
%       See also: MODULE_MEAN
%
% RL van den Brink, 2015

%% check input
if ~exist('center','var')
    center = 0;
end

if isempty(center)
    center = 0;
end

if nargin < 1 
    help module_plot
    return
end

if nargin < 2 
    center = 0;
end

defaultopts={'-k'};
if nargin<3 || isempty(plotopts)
    plotopts=defaultopts; 
end

if ~iscell(plotopts)
    plotopts={plotopts}; 
end

%% plot

%find borders between the modules
intersections = find(diff(modz));
nintersections = length(intersections);

%plot
shg
hold on
if ~center
    plot([intersections; intersections]+0.5,repmat([0; length(modz)+0.5],[1 nintersections]),plotopts{:})
    plot(repmat([0; length(modz)+0.5],[1 nintersections]),[intersections; intersections]+0.5,plotopts{:})
else
    intersections = [-0.5 intersections length(modz) length(modz)];
    for seci = 1:nintersections
        plot([intersections(seci+1) intersections(seci+1)]+0.5,[intersections(seci) intersections(seci+2)]+0.5,plotopts{:})
        plot([intersections(seci) intersections(seci+2)]+0.5,[intersections(seci+1) intersections(seci+1)]+0.5,plotopts{:})
    end

end

