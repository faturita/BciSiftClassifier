% run('C:\vlfeat-0.9.18\toolbox\vl_setup')
% BCI EPOC Emotiv Drowsiness Data
close all;clear;clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s\\*.*',getimagepath()));
end



epochRange = 1:30;
channelRange=1:14;
labelRange = [ones(1,15) ones(1,15)+1];
imagescale=1;


for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment

    if (label == 1)
        filename='EyesClosed';
    else
        filename='EyesOpen';
    end
       
    subject=mod(epoch,5)+1;
    session=ceil(epoch/5);
    
    %if (epoch>10)
    %    subject = epoch-10;
    %end
    
    output = loadepoceegraw(sprintf('Rodrigo//session%d',mod(session,label)+1),sprintf('eeg_%s_%i.dat',filename,mod(subject,10)),1); 

    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale);
    end

end


% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);