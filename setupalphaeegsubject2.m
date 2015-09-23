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
epochRange = 1:20;
channelRange=1:14;
labelRange = [ones(1,size(epochRange,2)/2) ones(1,size(epochRange,2)/2)+1];
imagescale=1;
siftscale=1;
siftdescriptordensity=1;
% =====================================

for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment
    
    
    if (epoch>(size(epochRange,2)/2))
        subject=epoch-(size(epochRange,2)/2);
    else
        subject=epoch;
    end
    
    %subject = epoch;
        
    %output = loadepoceegraw(sprintf('Rodrigo//session%d',mod(session,label)+1),sprintf('eeg_%s_%i.dat',filename,mod(subject,10)),1); 
    output=loadepoceegraw(sprintf('Rodrigo%sPestaneo',filesep),sprintf('e.%d.l.%d.dat',subject,label),1);

    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale);
    end

end


% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);