% P300 For ALS Patients

clear mex;clearvars  -except subject;close all;clc;

% Clean all the directories where the images are located.
cleanimagedirectory();

subject = 3;
load(sprintf('/Users/rramele/GoogleDrive/BCI.Dataset/008-2014/A%02d.mat',subject));


% NN.NNNNN
% data.X(sample, channel)
% data.y(sample)  --> 0: no, 1:nohit, 2:hit
% data.y_stim(sample) --> 1-12, 1-6 cols, 7-12 rows

% 3 is PZ

% Parameters ==========================
epochRange = 1:4200;
epochRange = 1:240;
channelRange=1:8;
labelRange = zeros(1,4200);
imagescale=1;    % Para agarrar dos decimales NN.NNNN
siftscale=3;  % 2 mvoltios y medio.
siftdescriptordensity=1;
Fs=256;
length=1;
expcode=1010;
% =====================================

epoch=0;

for trial=1:2     % subject
    for flash=0:119
            
        % 64 is the length of 32 stimulus + 32 rest.
        label=data.y(data.trial(trial)+64*flash);
        
        labels(flash+1) = label;
        
    end
    for flash=0:119
        label=labels(flash+1);
        output = data.X( (data.trial(trial)+64*flash):(data.trial(trial)+64*flash)+Fs*length-1,:);
    
        [n,m]=size(output);
        output=output - ones(n,1)*mean(output,1);
    
        epoch=epoch+1;
        labelRange(epoch) = label;
        for channel=channelRange
            image=eegimagescaled(epoch,label,output,channel,imagescale,1);
        end
    end

end

KS = 64:64+32-1;
KS = 64+32;
LOCS{1}.KS = 46:110;
LOCS{2}.KS = 93:146;
LOCS{3}.KS = 57:128;
LOCS{4}.KS = 37:91;
LOCS{5}.KS = 132:187;
LOCS{6}.KS = 79:127;
LOCS{7}.KS = 93:142;
LOCS{8}.KS = 49:150;

KS = LOCS{subject}.KS;
%KS = 8*(imagescale):8*(imagescale)+3*(imagescale)*2-1;
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1,KS);
F = LoadDescriptors(labelRange,epochRange,channelRange);

%F = SynthesizeDescriptors(F, labelRange, epochRange, channelRange,3*(imagescale));

% Recordar que testRange tiene que ser de largo igual cantidad de ambas
% clases para que ACC no de mal.


trainingRange=1:1800;
testRange=1801:4200;
trainingRange=1:120;
testRange=121:240;
% Parameters ==============================
graphics=0; comps=0;
%==========================================
ErrorPerChannel = ones(12,1)*0.5;
Pij=zeros(size(channelRange,2),1,1);


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
