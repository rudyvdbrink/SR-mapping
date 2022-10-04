function gsurfl(kdat,clim,cmap)
%usage: gsurf(kdat,clim,cmap)

warning('off','all')
filename = [pathfindr('gdir') 'Glasser_atlas.dlabel.nii'];

addpath(genpath(pathfindr('ftdir')))
addpath(genpath(pathfindr('gdir')))

%% load surface

% g = [gdir 'S1200.L.flat.32k_fs_LR.surf.gii'];
% g = [gdir 'S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii'];
g = [pathfindr('gdir') 'S1200.L.inflated_MSMAll.32k_fs_LR.surf.gii'];
% g = [gdir 'S1200.R.very_inflated_MSMAll.32k_fs_LR.surf.gii'];
% g = [gdir 'S1200.L.sphere.32k_fs_LR.surf.gii'];

g = gifti(g); %surface
atlas = ft_read_cifti(filename); %atlas

rmpath(genpath(pathfindr('ftdir')))

%% fill in glasser parcels

dat = atlas.brainstructure == 1;
dat = atlas.indexmax(dat);
dat(isnan(dat)) = 0;
ris  = unique(nonzeros(dat));

rdat_mapped = atlas;
rdat_mapped.indexmax = zeros(size(rdat_mapped.indexmax));

%get the value of each brain region
for rj = 1:length(ris)
    ri = ris(rj);
    idx = dat == ri;
    rdat_mapped.indexmax(idx) = kdat(rj);
end

rdat_mapped.indexmax(isnan(atlas.indexmax)) = nan;

dat = rdat_mapped.brainstructure == 1; 
dat = rdat_mapped.indexmax(dat);
dat(isnan(dat)) = 1000; 

cortsurfl(g,dat,cmap,clim)