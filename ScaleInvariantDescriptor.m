%run('C:/Users/rramele/workspace/vlfeat/toolbox/vl_setup')

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
epochRange = 1:1;
channelRange=1:1;
%labelRange = [ones(1,size(epochRange,2)/2) ones(1,size(epochRange,2)/2)+1];
labelRange = 1;
imagescale=1;
siftscale=1;
siftdescriptordensity=1;
% =========================


for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment
       
    output = fakeeegoutput(imagescale, label,128,14);    

    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale);
    end

end

KS = [10,60, 90];

% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1,KS);
F = LoadDescriptors(labelRange,epochRange,channelRange);

DisplayDescriptorImageFull(F,1,1,1,-1);


F(1,1,1).descriptors = [ sum(F(1,1,1).descriptors,2)];


