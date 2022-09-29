function Mz = module_mean(M,modz,varargin)
% MODULE_MEAN averages over module elements in a square matrix.
%
%   Usage:
%     Mz = module_mean(M,modz) 
%     Mz = module_mean(M,modz,collapse,incldiag) 
%
%   Input:
%     M:          square matrix to be averaged over
%     modz:       vector of module indices, with one numeric value per
%                 row/colum index of M 
%     collapse:   (optional) return (1) or not (0) a matrix collapsed
%                 across module elements (default: 0). If collapse is not 
%                 selected, Mz is the same size as M. If selected, Mz has 
%                 as many rows/columns as there are unique modules in modz.
%     incldiag:   (optional) include the diagonal in the average (1) or not
%                 (0). If the diagonal is excluded, the respective values 
%                 set to NaN and ignored in the average (default: 0).
%
%   Output:
%     Mz:         the matrix M averaged across module elements
%
%   Example:
%     M = rand(10); %create some random numbers
%     modz = [1 1 1 2 2 3 3 3 4 4]; %modules to average across
%     
%     figure
%     subplot(1,2,1)
%     imagesc(M) %plot the random number matrix
%     axis square %format the axis to be square
%     module_plot(modz,1,{'k','linewidth',2}) %outline the modules (on diagonal)
%     module_plot(modz,0,{'k--'}) %outline the modules (everywhere)
%     axis off %we don't need to see the ticks so turn them off
%     set(gca,'clim',[0 1]) %fix color range
% 
%     Mz = module_mean(M,modz,0,1); %average across module elements without collapsing and including the diagonal
%     
%     subplot(1,2,2)
%     imagesc(Mz)
%     axis square
%     module_plot(modz,1,{'k','linewidth',2}) %outline the modules (on diagonal)
%     module_plot(modz,0,{'k--'}) %outline the modules (everywhere)
%     axis off %we don't need to see the ticks so turn them off
%     set(gca,'clim',[0 1]) %fix color range, same as previous plot
%
%       See also: MODULE_PLOT
%
% RL van den Brink, 2015


%% Check input

if isempty(varargin) 
    collapse = 0;
    incldiag = 0;
else    
    if nargin < 2
        error('not enough input arguments')    
    elseif nargin == 3
        collapse = varargin{1};
        incldiag = 0;
    elseif nargin == 4
        collapse = varargin{1};
        incldiag = varargin{2};
    elseif nargin > 4
        error('too many input arguments')
    end
end

if isempty(collapse)
    collapse = 0;
end

if size(M,1) ~= size(M,2)
    error('input matrix M must be square')
end

if length(modz) ~= size(M,1) || ~isvector(modz)
    error('input modz must be a vector and same length as input matrix M')
end

%% Compute module mean

if ~incldiag
    M(logical(eye(size(M)))) = NaN; %set diagonal to NaN so that we exclude it from the mean
end

%find borders between the modules
intersections = find(diff(modz));
intersections = [0 intersections length(modz)];

%compute the average value per module-module elements
if collapse
    Mz = zeros(length(intersections)-1);    
    for mi = 1:length(intersections)-1
        for mj = 1:length(intersections)-1
            Mz(mi,mj) = mean(nanmean(M(intersections(mi)+1:intersections(mi+1),intersections(mj)+1:intersections(mj+1))));
        end
    end    
else
    Mz = M;
    for mi = 1:length(intersections)-1
        for mj = 1:length(intersections)-1
            Mz(intersections(mi)+1:intersections(mi+1),intersections(mj)+1:intersections(mj+1)) = mean(nanmean(M(intersections(mi)+1:intersections(mi+1),intersections(mj)+1:intersections(mj+1))));
        end
    end
end


