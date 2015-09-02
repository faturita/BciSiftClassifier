% run('C:\vlfeat-0.9.18\toolbox\vl_setup')
% BCI EPOC Emotiv Drowsiness Data
close all;clear;clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end

% Clean Descriptor Directory
if (exist(sprintf('%s',getdatabasepath()),'dir'))
    delete(sprintf('%s%s*.dat',getdatabasepath(),filesep));
end



% Parameters ==============
epochRange = 1:30;
channelRange=1:14;
labelRange = [ones(1,15) ones(1,15)+1];
imagescale=1;siftscale=1;siftdescriptordensity=12;
% =========================


for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment
       
    output = fakeeegoutput(imagescale, label);    

    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale);
    end

end

% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);
