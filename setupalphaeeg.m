% run('C:\vlfeat-0.9.18\toolbox\vl_setup')
% BCI EPOC Emotiv Drowsiness Data
close all;clear;clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end

% Parameters ==============
epochRange = 1:30;
channelRange=1:14;
labelRange = [ones(1,15) ones(1,15)+1];
imagescale=1;siftscale=1;siftdescriptordensity=1;
% =========================

for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment

    if (label == 1)
        filename='EyesClosed';
    else
        filename='EyesOpen';
    end
    
    if (epoch>=16)
        subject = epoch-15;
    else
        subject = epoch;
    end
    
    directory = sprintf('Rodrigo%s',filesep);
    file = sprintf('eeg_%s_%i.dat',filename,subject);
    
    fprintf('%s%s%s\n', directory, filesep, file );
    
    output = loadepoceegraw(directory,file,1); 

    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale);
    end

end


% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);