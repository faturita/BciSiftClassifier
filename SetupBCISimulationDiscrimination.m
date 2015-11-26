% ========================================================================
% This script performs a BCISimulation procedure for the BCISift
% classification algorithm, differentiating right-hand vs feet movement.
%
% USEME TO TEST FOR ONLY ONE SUBJECT
%
%
close all;clear;clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end

% Clean Descriptor Directory
if (exist(sprintf('%s',getdescriptorpath()),'dir'))
    delete(sprintf('%s%s*.dat',getdescriptorpath(),filesep));
end

% S02 da bien
load(sprintf('%s\002-2014\S02T.mat', getdatasetpath()));

% data{session}
% 
% ans = 
% 
%           X: [112128x15 double]
%       trial: [1x20 double]
%           y: [1 1 2 1 1 2 1 1 1 1 2 2 2 2 2 1 2 2 1 2]
%          fs: 512
%     classes: {'right hand'  'feet'}

% 0-----------2----------3-----------4.25----------------------8---8.5----10.5
%  Baseline  BEEP              CUE                 MI                 REST                           

% Parameters ==========================
channelRange=[5 8 11];
imagescale=1;
siftscale=4;
siftdescriptordensity=10;
siftinterpolated=1;
% =====================================

lbRange=[];
ep=1;

for session=1:5
    for trial=1:20
        r=0;
        label=data{session}.y(trial);
        lbRange = [lbRange label];
        output= data{session}.X(data{session}.trial(trial)+512*4.25+r*512:data{session}.trial(trial)+512*4.25+(r+1)*512-1,:);
            
        [n,m]=size(output);
        output=output - ones(n,1)*mean(output,1);

        for channel=channelRange
            image=eegimagescaled(ep,label,output,channel,imagescale, siftinterpolated);
        end
        ep=ep+1;
        % =================================
    end
end

load(sprintf('%s\002-2014\S02E.mat', getdatasetpath()));

for session=1:3
    for trial=1:20
        r=0;
        label=data{session}.y(trial);
        lbRange = [lbRange label];
        output= data{session}.X(data{session}.trial(trial)+512*4.5+r*512:data{session}.trial(trial)+512*4.5+(r+1)*512-1,:);
            
        [n,m]=size(output);
        output=output - ones(n,1)*mean(output,1);

        for channel=channelRange
            image=eegimagescaled(ep,label,output,channel,imagescale, siftinterpolated);
        end
        ep=ep+1;
    end
end

epochRange=1:ep-1;
labelRange=lbRange;

% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);

% Parameters ==============================
graphics=0; comps=0;
prompt = 'Experiment? ';
%expcode = input(prompt);
expcode=132;
%==========================================
Pij=zeros(size(channelRange,2),1,1);

trainingRange=1:100;
testRange=101:160;

for channel=channelRange
     
    % --------------------------
    Performance=[];
    %for channel=channelRange
    fprintf('Channel %d\n', channel);
    DE = BciSiftNBNNFeatureExtractor(F,expcode,channel,trainingRange,labelRange,graphics);
    [ACC, ERR, SC] = BciSiftNBNNClassifier(F,DE,channel,testRange,labelRange,0,0);
    Performance(channel, 1)= ACC;
    Pij(channel,1,1) = ERR;
end

ACCij=1-Pij/size(testRange,2);

if (graphics)
    figure
    bar(AccuracyPerChannel(channelRange));
    title(sprintf('Exp.%d:k(%d)-fold Cross Validation NBNN: %d, %1.2f',expcode,KFolds,siftdescriptordensity,siftscale));
    xlabel('Channel')
    ylabel('Accuracy')
    axis([0 size(channelRange,2)+1 0 1.3]);
end