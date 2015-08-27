% run('C:\vlfeat-0.9.18\toolbox\vl_setup')
% BCI EPOC Emotiv Drowsiness Data
close all;clear;clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end


epochRange = 1:20;
channelRange=1:14;
labelRange = [ones(1,10) ones(1,10)+1];
imagescale=1;
siftscale=1;
siftdescriptordensity=12;

for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment
    
    if (epoch>10)
        subject=epoch-10;
    else
        subject=epoch;
    end
    
    
    %output = loadepoceegraw(sprintf('Rodrigo//session%d',mod(session,label)+1),sprintf('eeg_%s_%i.dat',filename,mod(subject,10)),1); 
    output=loadepoceegraw('Rodrigo/Contar',sprintf('e.%d.l.%d.dat',subject,1),1);

        
    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale);
    end

end


% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);