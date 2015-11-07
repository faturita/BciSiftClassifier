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

load('C:\Users\User\Google Drive\BCI.Dataset\002-2014\S06T.mat');
error('No funca');

% data{session}
% 
% ans = 
% 
%           X: [112128x15 double]
%       trial: [1x20 double]
%           y: [1 1 2 1 1 2 1 1 1 1 2 2 2 2 2 1 2 2 1 2]
%          fs: 512
%     classes: {'right hand'  'feet'}

lbRange=[];

for session=1:5

% Parameters ==========================
epochRange = 1:60;
channelRange=[5 9 12];
labelRange = reshape(repmat(data{session}.y,3,1),[1 60]);
imagescale=1;
siftscale=6;
siftdescriptordensity=10;
% =====================================


for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment
    
    d = floor((epoch-1)/3)+1;
    
    r = mod(epoch-1, 3);
    
    [d r data{session}.trial(d) data{session}.trial(d)+512*4.25+r*512 data{session}.trial(d)+512*4.25+(r+1)*512];
    
    %output=data{session}.X(data{session}.trial(d)+512*r:data{session}.trial(d)+512*(r+1)-1,:);
    output= data{session}.X(data{session}.trial(d)+512*4.25+r*512:data{session}.trial(d)+512*4.25+(r+1)*512-1,:);
    
    [n,m]=size(output);
    output=output - ones(n,1)*mean(output,1);

    %output2=zeros(128,15);
    
    %for i=1:128
    %   output2(i,:)=output((i-1)*4+1,:);
    %end

    %output=output2;
        
    for channel=channelRange
        image=eegimagescaled((session-1)*60+epoch,label,output,channel,imagescale);
    end

end

lbRange = [lbRange labelRange];

end

epochRange=1:60*5;
labelRange=lbRange;

% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);