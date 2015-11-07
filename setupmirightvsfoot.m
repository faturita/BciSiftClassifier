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
error('NO FUNCA')
load('C:\Users\User\Google Drive\BCI.Dataset\002-2014\S02T.mat');

% data{session}
% 
% ans = 
% 
%           X: [112128x15 double]
%       trial: [1x20 double]
%           y: [1 1 2 1 1 2 1 1 1 1 2 2 2 2 2 1 2 2 1 2]
%          fs: 512
%     classes: {'right hand'  'feet'}

% Parameters ==========================
channelRange=[5 8 11];
imagescale=1;
siftscale=4;
siftdescriptordensity=5;
siftinterpolated=1;
% =====================================

lbRange=[];
ep=1;

for session=1:5
    for trial=1:20
            r=0;
            label=data{session}.y(trial);lbRange = [lbRange label];
            output= data{session}.X(data{session}.trial(trial)+512*6+r*512:data{session}.trial(trial)+512*6+(r+1)*128-1,:);
            
            output = output*10;
            %output= data{session}.X(data{session}.trial(trial)+r*512:data{session}.trial(trial)+(r+1)*512-1,:);
            
            output(:,5)  = output(:,5)  - 1/4 * (output(:,1)+output(:,4) +output(:,6) +output(:,13));
            output(:,8)  = output(:,8)  - 1/4 * (output(:,2)+output(:,7) +output(:,9) +output(:,14));
            output(:,11) = output(:,11) - 1/4 * (output(:,3)+output(:,10)+output(:,12)+output(:,15));
            
            [n,m]=size(output);
            output=output - ones(n,1)*mean(output,1);
            
            
            for channel=channelRange
                image=eegimagescaled(ep,label,output,channel,imagescale,siftinterpolated);
            end    
            ep=ep+1;
    end
end

epochRange=1:ep-1;
labelRange=lbRange;

% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);