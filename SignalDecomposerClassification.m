% Script: P300SingleTrialClassification.m

%% Classification
%print(fig,sprintf('%d-p300averagedpersubject%d.png',expcode,subject),'-dpng')
%clear('fig');
delta=1;
epochRange=1:epoch;
labelRange=labelRange(1:epoch);

% Restrict where to put the descriptors but based on the specified density
%assert( 64+min(KS)-siftscale*12/2 >= max(KS), sprintf('%d\n',64+min(KS)-siftscale*12/2))

KS=25:39;
KS=ceil(100*imagescale/downsize):ceil(156*imagescale/downsize);

SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1,KS);
F = LoadDescriptors(labelRange,epochRange,channelRange);

% Recordar que testRange tiene que ser de largo igual cantidad de ambas
% clases para que ACC no de mal.

% Parameters ==============================
graphics=0; comps=0;
prompt = 'Experiment? ';
%expcode = input(prompt);
%expcode=132;
%==========================================
ErrorPerChannel = ones(12,1)*0.5;
Pij=zeros(size(channelRange,2),1,1);

for channel=channelRange

    % --------------------------
    %for channel=channelRange
    fprintf('Channel %d\n', channel);
    DE = BciSiftNBNNFeatureExtractor(F,expcode,channel,trainingRange,labelRange,graphics);
    [ACC, ERR, SC] = BciSiftNBNNClassifier(F,DE,channel,testRange,labelRange,0,0);
    P = SC{1}.TN / (SC{1}.TN+SC{1}.FN);
    Performance(channel,delta) = ACC;
    Pij(channel,1,1) = ERR;
    Selectivity(channel,1,1) = SC{1}.TP/(SC{1}.TP+SC{1}.FP);
    ErrorPerChannel(channel)=ERR;
end

ACCij=1-Pij/size(testRange,2);
ACCijsigma=0;

AccuracyPerChannel = 1-ErrorPerChannel;
graphics = 0;
if (graphics)
    fig = figure
    plot(ACCij,'LineWidth',2);
    %title(sprintf('10-fold Cross Validation NBNN'));
    hx=xlabel('Channel');
    hy=ylabel('Accuracy');
    axis([1 8 0 1.0]);
    figurehandle=gcf;
    set(findall(figurehandle,'type','text'),'fontSize',14); %'fontWeight','bold');
    set(gca,'XTick', [1 3 5 8]);
    set(gca,'XTickLabel',{'Fz' ,     'Pz' ,      'P3',    'PO7'  });
    set(gca,'YTick', [0 0.8 0.9]);
    set(0, 'DefaultAxesFontSize',24);
    set(hx,'fontSize',20);
    set(hy,'fontSize',20);
    print(fig,sprintf('%d-p300alsaveragingsubject%d.png',expcode,subject),'-dpng')
end



% Data Visualization
% figure;
% subplot(2,2,1);
% epoch=1;
% plot((-1)*data.X(data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1):data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1)+Fs*length-1,2))
% axis([0 256 -30 30]);
% subplot(2,2,3);
% DisplayDescriptorImageFull(F,epoch,1,2,0);
% 
% subplot(2,2,2);
% epoch=2;
% plot((-1)*data.X(data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1):data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1)+Fs*length-1,2))
% axis([0 256 -30 30]);
% 
% subplot(2,2,4);
% DisplayDescriptorImageFull(F,epoch,2,2,0);