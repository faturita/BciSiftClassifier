%run('C:/Users/rramele/workspace/vlfeat/toolbox/vl_setup')

clear mex;clear all;close all;clear;clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end

% Clean Descriptor Directory
if (exist(sprintf('%s',getdescriptorpath()),'dir'))
    delete(sprintf('%s%s*.dat',getdescriptorpath(),filesep));
end

% Parameters ==============
epochRange = 1:300;
channelRange=1:1;
labelRange = [ones(1,100) ones(1,100)+1 ones(1,50) ones(1,50)+1];
%labelRange = 1;
imagescale=1;
siftscale=1;
siftdescriptordensity=1;
% =========================


for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment
       
    output = fakeeegoutput(imagescale, label,128,14);    

    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale);
    end

end

KS = [10,60, 90];

% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1,KS);
F = LoadDescriptors(labelRange,epochRange,channelRange);

F = SynthesizeDescriptors(F, labelRange, epochRange, channelRange);

% DisplayDescriptorImageFull(F,1,1,1,-1);


% Parameters ==============================
graphics=0; comps=0;
prompt = 'Experiment? ';
%expcode = input(prompt);
expcode=132;
%==========================================
ErrorPerChannel = ones(12,1)*0.5;
Pij=zeros(size(channelRange,2),1,1);

trainingRange=1:200;
testRange=201:300;

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



