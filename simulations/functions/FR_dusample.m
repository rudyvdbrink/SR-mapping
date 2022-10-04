function dat = FR_dusample(dat,upsamplefactor);
% data = FR_dusample(data,upsamplefactor)
%
% First downsamples the data, and then upsamples it again. 
%
% Input:
%  data: Voxels x time matrix
%  upsamplefactor: how much to down/upsample the data
%
% Output:
%  data: Voxels x time matrix

dat_new = nan(size(dat));

dat = cat(2,dat,repmat(dat(:,end),[1 upsamplefactor])); %pad
dat = dat(:,1:upsamplefactor:end); %downsample

for vi = 1:size(dat,1)    
    tmp = interp(dat(vi,:),upsamplefactor);
    dat_new(vi,:) = tmp(1:size(dat_new,2));    
end

dat = dat_new;