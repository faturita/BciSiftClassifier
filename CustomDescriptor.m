% run('/Users/rramele/work/vlfeat-0.9.20/toolbox/vl_setup')
close all;clearvars;clc;

% Parameters ==============
epochRange = 1:1;
channelRange=1:1;
labelRange = 1:1;
imagescale=1;
siftscale=2;
siftdescriptordensity=1;
% =========================

label = 1;
epoch=1;
channel=1;
output = fakeeegoutput(imagescale, label,channelRange,128);  

image=eegimagescaled(epoch,label,output,channel,imagescale);


SAMPLELOCS = [ 20 ];

fprintf('Saving Descriptors...\n');
psiftscale=siftscale;
for epoch=epochRange
    for channel=channelRange
        label=labelRange(epoch);
        [frames, desc] = PlaceDescriptor(channel,label,epoch, psiftscale, SAMPLELOCS);

        dlmwrite(sprintf('%ssift.data.e.%d.l.%d.c.%d.descriptors.dat',getdescriptorpath(),epoch,label,channel), desc);
        dlmwrite(sprintf('%ssift.data.e.%d.l.%d.c.%d.frames.dat',getdescriptorpath(),epoch,label,channel), frames);


        F(channel,label,epoch).descriptors = desc;
        F(channel,label,epoch).frames = frames;

    end
end

DisplayDescriptorImageFull(F,epoch,label,channel,-1);
d = F(epoch, label, channel).descriptors(:,1);
reshape(d',8,16)
