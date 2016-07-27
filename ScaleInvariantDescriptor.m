run('C:/vlfeat/toolbox/vl_setup')

clear mex;clear all;
clear mex;clear all;close all;clear;clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end

% Clean Descriptor Directory
if (exist(sprintf('%s',getdescriptorpath()),'dir'))
    delete(sprintf('%s%s*.dat',getdescriptorpath(),filesep));
end

% Parameters ==============
epochRange = 1:300;
channelRange=1:14;
labelRange = [ones(1,size(epochRange,2)/2) ones(1,size(epochRange,2)/2)+1];
imagescale=1;
siftscale=0.5;
siftdescriptordensity=12;
% =========================


for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment
       
    output = fakeeegoutput(imagescale, label,512);    

    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale);
    end

end

% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);