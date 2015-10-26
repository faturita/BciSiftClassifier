% run('C:\vlfeat-0.9.18\toolbox\vl_setup')
% BCI EPOC Emotiv Drowsiness Data
close all;clear;clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end

% Clean Descriptor Directory
if (exist(sprintf('%s',getdescriptorpath()),'dir'))
    delete(sprintf('%s%s*.dat',getdescriptorpath(),filesep));
end

% Eyes open
[hdr, record1]=edfread('C:\Users\User\Desktop\Data\Datasets\S001R01.edf');
% Eyes closed
[hdr, record2]=edfread('C:\Users\User\Desktop\Data\Datasets\S001R02.edf');

record1=record1';
record2=record2';


% Parameters ==========================
epochRange = 1:120;
channelRange=1:64;
labelRange = [ones(1,60) ones(1,60)+1];
imagescale=1;
siftscale=1;
siftdescriptordensity=24;
% =====================================

for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment
    
    if (label==1)
        record=record1;
        e=epoch;
    else
        record=record2;
        e=epoch-60;
    end
        
    d = e-1;
    
    [epoch 160*d+1 160*(d+1)]
    
    output=record(160*d+1:160*(d+1),:);
    
    [n,m]=size(output);
    output=output - ones(n,1)*mean(output,1);
    
    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale);
    end

end

% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);