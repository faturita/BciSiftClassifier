% This script process the inter-subject dataset
% presented HERE.  Get the images that are generated
% from the dataset and use them to generate a set of descriptors
% which can be used later to analyze and classify the images.

close all;clear;clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end

% Clean Descriptor Directory
if (exist(sprintf('%s',getdescriptorpath()),'dir'))
    delete(sprintf('%s%s*.dat',getdescriptorpath(),filesep));
end


% Parameters ==========================
channelRange=1:14;
labelRange = [ones(1,10) ones(1,10)+1];
imagescale=1;
siftscale=1;
siftdescriptordensity=1;
% =====================================

ep=1;
lbRange=[];

for epoch=1:20     % subject

    label=labelRange(epoch);   % experiment
    
    if (epoch>=11)
        epochfileindex=epoch-10;
    else
        epochfileindex=epoch;
    end
    
    output=loadepoceegraw(sprintf('Subjects%s',filesep),sprintf('e.%d.l.%d.dat',epochfileindex,label),1);

    for b=1:10
    
        otp = output(128*(b-1)+1:128*(b),:);
        
        for channel=channelRange
            image=eegimagescaled(ep,label,otp,channel,imagescale,0);
        end
    
        ep=ep+1;
        lbRange = [lbRange label];
    end

end
epochRange=1:ep-1;
labelRange=lbRange;

% Generate and Save all the descriptors...
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);


% Parameters ==============================
graphics=1; comps=0;
prompt = 'Experiment? ';
%expcode = input(prompt);
expcode=150;
%==========================================
ErrorPerChannel = ones(1,size(channelRange,2));

T=1;
KFolds=10;
Pij=zeros(size(channelRange,2),T,KFolds);


for channel=channelRange
    E = zeros(T,1);
    
    for t=1:T
        
        kfolds = fold(KFolds, epochRange);
        
        N = zeros(KFolds,1);
        
        for f=1:KFolds
            
            trainingRange=defold(kfolds, f);
            testRange=kfolds{f};
            
            
            % --------------------------
            Performance=[];
            %for channel=channelRange
            fprintf('Channel %d\n', channel);
            DE = BciSiftNBNNFeatureExtractor(F,expcode,channel,trainingRange,labelRange,graphics);
            [ACC, ERR, SC] = BciSiftNBNNClassifier(F,DE,channel,testRange,labelRange,0,0);
            Performance(channel, 1)= ACC;
            N(f) = ERR;
            Pij(channel,t,f) = ERR;
            
            
            % -hat -----------------------
            
        end
        
        E(t) = sum(N)/size(epochRange,2);
        
    end
    
    e= sum(E)/T;
    V = (sum((( E - e ).^2)))  / (T-1);
    sigma = sqrt( V );
    ErrorPerChannel(channel)=e;
    SigmaPerChannel(channel)=sigma;
end

SigmaPerChannel=SigmaPerChannel.*(1.645/(sqrt(T)));
AccuracyPerChannel = 1-ErrorPerChannel;

if (graphics)
    figure
    
    errorbar(AccuracyPerChannel, SigmaPerChannel,'LineWidth',2);
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

