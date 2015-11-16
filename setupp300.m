close all; clear; clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end

% Clean Descriptor Directory
if (exist(sprintf('%s',getdescriptorpath()),'dir'))
    delete(sprintf('%s%s*.dat',getdescriptorpath(),filesep));
end


load('/Users/rramele/Desktop/Data/p300/subject1/session1/eeg_200605191428_epochs.mat');
extracttrials('/Users/rramele/Desktop/Data/p300/subject1/session1','p300eeg');

p300 = load('p300eeg');


% x(channel, time, trial)

plot(p300.runs{1}.x(1,:,4))

% 13 is PZ

% Parameters ==========================
epochRange = 1:135;
channelRange=1:32;
labelRange = p300.runs{1}.y;
labelRange(labelRange == 1 ) = 2;   % Hit
labelRange(labelRange == -1) = 1;   % Nohit
imagescale=10;
siftscale=1;
siftdescriptordensity=1;
% =====================================

for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment
    
    output = p300.runs{1}.x(:, :,epoch)';
    
    [n,m]=size(output);
    output=output - ones(n,1)*mean(output,1);
    
    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale,1);
    end

end


% Generate and Save all the descriptors...
%SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
%F = LoadDescriptors(labelRange,epochRange,channelRange);
labelRange2 = p300.runs{2}.y;
labelRange2(labelRange2 == 1 ) = 2;   % Hit
labelRange2(labelRange2 == -1) = 1;   % Nohit

epochRange2=1:132;

for epoch=epochRange2     % subject

    label=labelRange2(epoch);   % experiment
    
    output = p300.runs{2}.x(:, :,epoch)';
    
    for channel=channelRange
        image=eegimagescaled(epoch+135,label,output,channel,imagescale,1);
    end

end


epochRange=[epochRange epochRange2+135];
labelRange=[labelRange(1:135) labelRange2];

SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);


% Recordar que testRange tiene que ser de largo igual cantidad de ambas
% clases para que ACC no de mal.


epochRange=epochRange(1:263);
labelRange=labelRange(1:263);

trainingRange=1:135;
testRange=136:263;