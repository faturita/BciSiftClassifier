% 
% We first get 300 epochs of 1 second each at 128 Fs
% 100 class 1, 100 class 2, 50 class 1, 50 class 2, balanced
%
% Class 1 is a fake P300 signal which is generated at 38 and the size is 12
%
% Class 2 is normal noise.
%
% EEG noise was generated by phasereset, amp 10
%
% 24 normalized descriptores are generated from 38th to 38+24th
%
% These descriptors are synthesized into 12, convolving on each dimension.
%
%
% Clasification using NNBN is later performed.
%
%run('C:/Users/rramele/workspace/vlfeat/toolbox/vl_setup')
%addpath('/Users/rramele/work/BciHotaru/phasereset')


clear mex;clear all;close all;clear;clc;

% Clean all the directories where the images are located.
cleanimagedirectory();

% Parameters ==============
epochRange = 1:120;
channelRange=1:1;
labelRange = [ones(1,100) ones(1,100)+1 ones(1,50) ones(1,50)+1];
labelRange = randi(2,1,120);
%labelRange = 1;
imagescale=1;
siftscale=4;
siftdescriptordensity=1;
Fs=256;
length=1;
% =========================


for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment
       
    output = fakep300(imagescale, label,channelRange,Fs);    

    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale);
    end

end

% 38, Remember to consider the scale. This should go to a function
% KS = 38:38+12*2-1;

%KS = 38*(imagescale):38*(imagescale);

delta=2;
% Restrict where to put the descriptors but based on the specified density
KS = 64:64+32-1;
KS = 64+40+delta;
KS = 86+floor(46/2);

% Generate and Save all the descriptors...
% Si te quedas con F de aca pincha por el tipo de dato.
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1,KS);
F = LoadDescriptors(labelRange,epochRange,channelRange);

%F = SynthesizeDescriptors(F, labelRange, epochRange, channelRange,12);

% DisplayDescriptorImageFull(F,1,1,1,-1);


% Parameters ==============================
graphics=0; comps=0;
prompt = 'Experiment? ';
%expcode = input(prompt);
expcode=132;
%==========================================
ErrorPerChannel = ones(12,1)*0.5;
Pij=zeros(size(channelRange,2),1,1);

trainingRange=1:100;
testRange=101:120;
delta=1;

for channel=channelRange

    % --------------------------
    Performance=[];
    %for channel=channelRange
    fprintf('Channel %d\n', channel);
    DE = BciSiftNBNNFeatureExtractor(F,expcode,channel,trainingRange,labelRange,graphics);
    [ACC, ERR, SC] = BciSiftNBNNClassifier(F,DE,channel,testRange,labelRange,0,0);
    Performance(channel, delta)= SC{1}.TN / (SC{1}.TN+SC{1}.FN);
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

figure;
subplot(2,1,1);
epoch=find(labelRange==2);
epoch=epoch(1);
DisplayDescriptorImageFull(F,epoch,2,1,-1);

subplot(2,1,2);
epoch=find(labelRange==2);
epoch=epoch(2);
DisplayDescriptorImageFull(F,epoch,2,1,-1);

