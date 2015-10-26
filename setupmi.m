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

load('C:\Users\User\Google Drive\BCI.Dataset\002-2014\S01T.mat');

% data{1}
% 
% ans = 
% 
%           X: [112128x15 double]
%       trial: [1x20 double]
%           y: [1 1 2 1 1 2 1 1 1 1 2 2 2 2 2 1 2 2 1 2]
%          fs: 512
%     classes: {'right hand'  'feet'}


% Parameters ==========================
epochRange = 1:200;
channelRange=1:15;
labelRange = reshape(repmat(data{1}.y,10,1),[1 200]);
imagescale=1;
siftscale=1;
siftdescriptordensity=1;
% =====================================

for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment
    
    d = floor((epoch-1)/10)+1;
    
    r = mod(epoch-1, 10);
    
    %[d data{1}.trial(d) data{1}.trial(d)+512*r data{1}.trial(d)+512*(r+1)-1]
    
    output=data{1}.X(data{1}.trial(d)+512*r:data{1}.trial(d)+512*(r+1)-1,:);
    
    [n,m]=size(output);
    output=output - ones(n,1)*mean(output,1);
    
    output2=zeros(128,15);
    
    for i=1:128
        output2(i,:)=output((i-1)*4+1,:);
    end

    output=output2;
        
    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale);
    end

end

% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);