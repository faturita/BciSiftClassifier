% run('/Users/rramele/work/vlfeat-0.9.20/toolbox/vl_setup')
close all;clearvars;clc;

% Clean all the directories where the images are located.
cleanimagedirectory();

% Parameters ==============
epochRange = 1:30;
channelRange=1:1
labelRange = [ones(1,10) ones(1,10)+1 ones(1,5) ones(1,5)+1];
imagescale=1;
siftscale=1;
siftdescriptordensity=1;
% =========================

% Calculate descriptors
for epoch=epochRange     % subject

    label=labelRange(epoch);   % experiment
       
    output = fakeeegoutput(imagescale, label,channelRange,128);    

    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale);
    end

end

% Where we should put descriptors.  Samples.
SAMPLELOCS = [ 20, 70, 90];

fprintf('Saving Descriptors...\n');
psiftscale=siftscale;
for epoch=epochRange
    for channel=channelRange
        label=labelRange(epoch);
        % Read images from the filesystem and calculates the descriptors.
        [frames, desc] = PlaceDescriptor(channel,label,epoch, psiftscale, SAMPLELOCS);

        dlmwrite(sprintf('%ssift.data.e.%d.l.%d.c.%d.descriptors.dat',getdescriptorpath(),epoch,label,channel), desc);
        dlmwrite(sprintf('%ssift.data.e.%d.l.%d.c.%d.frames.dat',getdescriptorpath(),epoch,label,channel), frames);
        
        desc = sum(desc,2);  % Sum descriptors.
        frames = frames(:,1);  % I arbitrary pick one.
        
        F(channel,label,epoch).descriptors = desc;
        F(channel,label,epoch).frames = frames;

    end
end

%DisplayDescriptorImageFull(F,epoch,label,channel,-1);
%d = F(epoch, label, channel).descriptors(:,1);
%reshape(d',8,16)



% Classification Parameters ===============
graphics=0; comps=0;
expcode=132;
%==========================================
ErrorPerChannel = ones(12,1)*0.5;
Pij=zeros(size(channelRange,2),1,1);

trainingRange=1:20;
testRange=21:30;

for channel=channelRange

    % --------------------------
    Performance=[];
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


