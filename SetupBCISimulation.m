% ========================================================================
% This script performs a BCISimulation procedure for the BCISift
% classification algorithm, differentiating right-hand vs feet movement.
%
% run('/Users/rramele/work/vlfeat-0.9.20/toolbox/vl_setup')
% For all subjects
for subject=13:13

close all;clearvars -except subject;clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end

% Clean Descriptor Directory
if (exist(sprintf('%s',getdescriptorpath()),'dir'))
    delete(sprintf('%s%s*.dat',getdescriptorpath(),filesep));
end

% S02 da bien
load(sprintf('%s/002-2014/S%02dT.mat', getdatasetpath(), subject));

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
channelRange=[11];
imagescale=1;
siftscale=6;
siftdescriptordensity=10;
siftinterpolated=0;
% =====================================

lbRange=[];
ep=1;

for session=1:5
    for trial=1:20
        if ( data{session}.y(trial) == 1)

            r=0;
            label=1;lbRange = [lbRange label];
            output= data{session}.X(data{session}.trial(trial)+ r*512:data{session}.trial(trial)+(r+1)*512-1,  :);

            
            output = LaplacianSpatialFilter(output,11,3,10,12,15);
            
            [n,m]=size(output);
            output=output - ones(n,1)*mean(output,1);

            for channel=channelRange
                image=eegimagescaled(ep,label,output,channel,imagescale, siftinterpolated);
            end
            ep=ep+1;
            % =================================

            r=0;
            offset=4.5;
            label=2;lbRange = [lbRange label];
            output= data{session}.X(data{session}.trial(trial)+512*offset+r*512:data{session}.trial(trial)+512*offset+(r+1)*512-1,:);

            output = LaplacianSpatialFilter(output,11,3,10,12,15);
            
            [n,m]=size(output);
            output=output - ones(n,1)*mean(output,1);

            for channel=channelRange
                image=eegimagescaled(ep,label,output,channel,imagescale, siftinterpolated);
            end
            ep=ep+1;
        end
    end
end

clear data;
load(sprintf('%s/002-2014/S%02dE.mat', getdatasetpath(), subject));

for session=1:3
    for trial=1:20
        if ( data{session}.y(trial) == 1)

            r=0;
            label=1;lbRange = [lbRange label];
            output= data{session}.X(data{session}.trial(trial)+ r*512:data{session}.trial(trial)+(r+1)*512-1,  :);

            output = LaplacianSpatialFilter(output,11,3,10,12,15);
            
            [n,m]=size(output);
            output=output - ones(n,1)*mean(output,1);

            for channel=channelRange
                image=eegimagescaled(ep,label,output,channel,imagescale, siftinterpolated);
            end
            ep=ep+1;
            % =================================

            r=0;
            offset=4.5;
            label=2;lbRange = [lbRange label];
            output= data{session}.X(data{session}.trial(trial)+512*offset+r*512:data{session}.trial(trial)+512*offset+(r+1)*512-1,:);
            
            output = LaplacianSpatialFilter(output,11,3,10,12,15);
            
            [n,m]=size(output);
            output=output - ones(n,1)*mean(output,1);

            for channel=channelRange
                image=eegimagescaled(ep,label,output,channel,imagescale, siftinterpolated);
            end
            ep=ep+1;
        end
    end
end

epochRange=1:ep-1;
labelRange=lbRange;

% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1,[]);
F = LoadDescriptors(labelRange,epochRange,channelRange);

% Parameters ==============================
graphics=0; comps=0;
prompt = 'Experiment? ';
%expcode = input(prompt);
expcode=132;
%==========================================
ErrorPerChannel = ones(12,1)*0.5;
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
    Selectivity(channel,1,1) = SC{1}.TP/(SC{1}.TP+SC{1}.FP);
    ErrorPerChannel(channel)=ERR;
end

ACCij=1-Pij/size(testRange,2);

AccuracyPerChannel = 1-ErrorPerChannel;

if (graphics)
    figure
    plot(ACCij,'LineWidth',2);
    %title(sprintf('10-fold Cross Validation NBNN'));
    hx=xlabel('Channel');
    hy=ylabel('Accuracy');
    axis([1 14 0 1.0]);
    figurehandle=gcf;
    set(findall(figurehandle,'type','text'),'fontSize',14); %'fontWeight','bold');
    set(gca,'XTick', [1 7 8 14]);
    set(gca,'XTickLabel',{'Af3', 'O1','O2', 'Af4'});
    set(gca,'YTick', [0 0.7]);
    set(0, 'DefaultAxesFontSize',24);
    set(hx,'fontSize',20);
    set(hy,'fontSize',20);
end

%save(sprintf('S.%d.T.2.mat',subject));

end
