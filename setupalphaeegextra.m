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


% Parameters ==========================
epochRange = 1:200;
channelRange=1:14;
labelRange = [ones(1,100) ones(1,100)+1];
imagescale=1;
siftscale=1;
siftdescriptordensity=12;
siftinterpolated=1;
% =====================================

for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment

    if (epoch>=101)
        epochfileindex=epoch-100;
    else
        epochfileindex=epoch;
    end

    output=loadepoceegraw(sprintf('Rodrigo%sMano',filesep),sprintf('e.%d.l.%d.dat',epochfileindex,label),1);

    %label=randi(2);
    %labelRange(epoch)=label;

    %label=((label-1) && 1)+1;
    %labelRange(epoch) = label;

    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale,siftinterpolated);
    end
end

% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);
