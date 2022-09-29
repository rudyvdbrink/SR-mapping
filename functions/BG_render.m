function BG_render(indat,clim,surface)
% BG_render(indat,clim,surface)
%
% Make a 3D plot of the basal ganglia and thalamus with a specified value
% for these ROIs, indicated by color. 
%
% Indat should be a vector of length 3, with the indices corresponding to:
%   1 = Caudate
%   2 = Putamen
%   3 = Thalamus
%
% Clim is the color range for plotting.
%
% Surface should be a string variable, and determines the surface used for 
% plotting. It can be:
%   'midthickness'
%   'inflated'
%   'very_inflated'

%% check input

if ~exist('indat','var')
    error('Enter input data')
end

if ~exist('clim','var')
    clim = [min(indat) max(indat)];
end

if ~exist('surface','var')
    surface = 'inflated';
end

if isempty(indat)
    error('Input data empty')
end

if length(indat) ~= 3
    error('Incorrectly sized input data')
end

if isempty(clim)
   clim = [min(indat) max(indat)];
end

if isempty(surface)
    surface = 'inflated';
end


%% add paths

addpath(genpath('~\Surface_projection'))
addpath('~\smoothpatch_version1b\')
addpath('~\NIFTI_20110921')
atlasdir = '~\atlases\';

%% load brain

gdir = pathfindr('gdir');
hemi = 'R';

gname = [gdir 'S1200.' hemi '.' surface '_MSMAll.32k_fs_LR.surf.gii'];
g = gifti(gname); %surface

%make the surface fit to the subcortex
g.faces    = g.faces(:,[2 1 3]);
g.vertices = (g.vertices(:,[2 1 3])+50)/2;
g.vertices(:,1) = g.vertices(:,1)+40;
g.vertices(:,2) = g.vertices(:,2)+17;
g.vertices(:,3) = g.vertices(:,3)+7;

color = [1 1 1]; %RGB encoding of surface brain

figure
set(gcf,'color','w')

trisurf(g.faces,g.vertices(:,1),g.vertices(:,2),g.vertices(:,3),ones(length(g.faces),1),'edgealpha',0,'facealpha',0.3,'facecolor',color)

%% load ROIs

atlas = load_untouch_nii([atlasdir 'BG_plus_th_mask.nii']);
atlas = atlas.img;

%delete right hemisphere
atlas(atlas == 2) = 0;
atlas(atlas == 4) = 0;
atlas(atlas == 6) = 0;
atlas(atlas == 8) = 0;

%delete accumbens
atlas(atlas == 5) = 0;

%% plot the ROIs

ris = nonzeros(unique(atlas));

% color = [ 0 0 0 ];

cmap = inferno;

cidx = nan(3,1);
for vi = 1:3
    cidx(vi) = round(linmap(indat(vi),clim,[1 length(cmap)]));
end

cidx(cidx<1) = 1;
cidx(cidx>length(cmap)) = length(cmap);


for ri = 1:length(ris)
    
    roi = atlas == ris(ri);
    
    %extract structure surface
    FV=isosurface(roi);
    FV = smoothpatch(FV,1,3);
    t = FV.faces;
    p = FV.vertices;
    
    %plot
    hold on
    axis equal
    h=trisurf(t,p(:,1),p(:,2),p(:,3),'facealpha',1,'facecolor',cmap(cidx(ri),:),'edgealpha',0,'edgecolor',cmap(cidx(ri),:));
end

axis vis3d
axis off
camlight left

view([-164.7000 37.6800])
