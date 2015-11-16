% This script performs a CrossValidation procedure for the BCISift
% classification algorithm, differentiating baseline vs right-hand
% movement.
for subject=1:14

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
load(sprintf('C:\\Users\\User\\Google Drive\\BCI.Dataset\\002-2014\\S%02dT.mat',subject));

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
siftscale=6;
siftdescriptordensity=5;
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
            
            [n,m]=size(output);
            output=output - ones(n,1)*mean(output,1);

            for channel=channelRange
                image=eegimagescaled(ep,label,output,channel,imagescale, siftinterpolated);
            end
            ep=ep+1;
            % =================================
            
            r=1;
            label=2;lbRange = [lbRange label];
            output= data{session}.X(data{session}.trial(trial)+512*4.25+r*512:data{session}.trial(trial)+512*4.25+(r+1)*512-1,:);
            
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
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);


% Parameters ==============================
graphics=0; comps=0;
prompt = 'Experiment? ';
%expcode = input(prompt);
expcode=132;
%==========================================
ErrorPerChannel = ones(12,1)*0.5;

T=3;
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
            
            
            if (graphics)
                figure
                plot(Performance(channel,:));
                title(sprintf('Exp.%d:Channel %10.3f - MinPts %10.3f', expcode, channel, minPts));
                xlabel('DbscanRadio')
                ylabel('ACC')
                axis([0 500 0 1.3]);
            end
            
            % ------------------------
            
        end
        
        E(t) = sum(N)/size(epochRange,2);
        
    end
    
    e= sum(E)/T;
    V = (sum( (( E - e ).^2) )  )/ (T-1);
    sigma = sqrt( V );
    ErrorPerChannel(channel)=e;
    SigmaPerChannel(channel)=sigma;
end

AccuracyPerChannel = 1-ErrorPerChannel ;

if (graphics)
    figure
    bar(AccuracyPerChannel(channelRange));
    title(sprintf('Exp.%d:k(%d)-fold Cross Validation NBNN: %d, %1.2f',expcode,KFolds,siftdescriptordensity,siftscale));
    xlabel('Channel')
    ylabel('Accuracy')
    axis([0 size(channelRange,2)+1 0 1.3]);
end


save(sprintf('S.%d.T.mat', subject));

end