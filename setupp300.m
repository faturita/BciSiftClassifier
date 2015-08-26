% run('C:\vlfeat-0.9.18\toolbox\vl_setup')
% BCI EPOC Emotiv Drowsiness Data
close all;clear;clc;

if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end


load('/Users/rramele/Desktop/Data/p300/subject1/session1/eeg_200605191428_epochs.mat');
extracttrials('/Users/rramele/Desktop/Data/p300/subject1/session1','p300eeg');

p300 = load('p300eeg');


% x(channel, time, trial)

plot(p300.runs{1}.x(1,:,4))

epochRange = 1:135;
channelRange=1:32;
labelRange = p300.runs{1}.y;
labelRange(labelRange == 1 ) = 2;   % Hit
labelRange(labelRange == -1) = 1;   % Nohit

    
imagescale=1;
siftscale=1;
siftdescriptordensity=12;

for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment
    
    output = p300.runs{1}.x(:, :,epoch)';
    
    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale);
    end

end


% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);


