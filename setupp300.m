
close all; clear; clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end

% Clean Descriptor Directory
if (exist(sprintf('%s',getdescriptorpath()),'dir'))
    delete(sprintf('%s%s*.dat',getdescriptorpath(),filesep));
end

load('/Users/rramele/Data/p300/subject1/session1/eeg_200605191428_epochs.mat');
extracttrials('/Users/rramele/Data/p300/subject1/session1','p300eeg');

p300 = load('p300eeg');


% N.NNNNN
% x(channel, time, trial)
plot(p300.runs{1}.x(1,:,4))

% 13 is PZ

% Parameters ==========================
epochRange = [1:135 136:136+127-1];
channelRange=13:13;
labelRange = [p300.runs{1}.y(1:135) p300.runs{2}.y(1:127)];
labelRange(labelRange == 1 ) = 2;   % Hit
labelRange(labelRange == -1) = 1;   % Nohit
imagescale=10;    % Para agarrar dos decimales NN.NNNN
siftscale=3;  % 2 mvoltios y medio.
siftdescriptordensity=1;
% =====================================

epoch=0;

for trial=1:135     % subject

    epoch=epoch+1;
    
    label=labelRange(epoch);   % experiment
    
    output = p300.runs{1}.x(:, :,trial)';
    
    [n,m]=size(output);
    output=output - ones(n,1)*mean(output,1);
    
    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale,1);
    end

end


for trial=1:127     % subject
    
    epoch=epoch+1;
    
    label=labelRange(epoch);   % experiment
    
    output = p300.runs{2}.x(:, :,trial)';
    
    [n,m]=size(output);
    output=output - ones(n,1)*mean(output,1);
    
    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale,1);
    end

end

KS = 8*(imagescale):8*(imagescale)+3*(imagescale)*2-1;
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1,KS);
F = LoadDescriptors(labelRange,epochRange,channelRange);

F = SynthesizeDescriptors(F, labelRange, epochRange, channelRange,3*(imagescale));


% Recordar que testRange tiene que ser de largo igual cantidad de ambas
% clases para que ACC no de mal.


trainingRange=1:135;
testRange=136:262;
% Parameters ==============================
graphics=0; comps=0;
prompt = 'Experiment? ';
%expcode = input(prompt);
expcode=132;
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

