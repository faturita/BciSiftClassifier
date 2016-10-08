% P300 for ALS patients.
%run('C:/vlfeat/toolbox/vl_setup.m')
close all; clear; clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end

% Clean Descriptor Directory
if (exist(sprintf('%s',getdescriptorpath()),'dir'))
    delete(sprintf('%s%s*.dat',getdescriptorpath(),filesep));
end


load(sprintf('%s/%s',getdatasetpath(),'/BCI.Competition.II.Dataset.2b/data/AAS010R01.mat'));

% NN.NNNNN
% data.X(sample, channel)
% data.y(sample)  --> 0: no, 1:nohit, 2:hit
% data.y_stim(sample) --> 1-12, 1-6 cols, 7-12 rows

TrialStart=[];
whichtrial=0;
for i=1:size(trialnr,1)
    if (whichtrial ~= trialnr(i))
        whichtrial = trialnr(i);
        TrialStart=[TrialStart; i];
    end
end

% 11 is CZ

% Parameters ==========================
epochRange = 1:size(TrialStart,1);
channelRange=1:20;
labelRange = zeros(1,size(TrialStart,1));
imagescale=1;    % Para agarrar dos decimales NN.NNNN
siftscale=4;  % 2 mvoltios y medio.
siftdescriptordensity=1;
Fs=240;
length=1;
% =====================================

epoch=0;
labelRange = zeros(1,size(TrialStart,1));

for trial=1:size(TrialStart,1)
    epoch=epoch+1;

    label=StimulusType(TrialStart(trial))+1;
    labelRange(epoch) = label;

    output = signal(TrialStart(trial):TrialStart(trial)+Fs*length-1,:)/100;
    
    [n,m]=size(output);
    output=output - ones(n,1)*mean(output,1);

    for channel=channelRange
        image=eegimagescaled(epoch,label,output,channel,imagescale,1);
    end

end


KS = 64:64+32-1;
KS = 64+32;
%KS = 8*(imagescale):8*(imagescale)+3*(imagescale)*2-1;
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1,KS);
F = LoadDescriptors(labelRange,epochRange,channelRange);

%F = SynthesizeDescriptors(F, labelRange, epochRange, channelRange,3*(imagescale));

% Recordar que testRange tiene que ser de largo igual cantidad de ambas
% clases para que ACC no de mal.

trainingRange=1:500;
testRange=501:540;
%trainingRange=1:120;
%testRange=121:240;
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

fdsfs


for trial=1:size(TrialStart,1)
  output = signal(TrialStart(trial):TrialStart(trial)+Fs*length-1,:)/100;
  hold on;
  if (labelRange(trial) == 1)
    plot(output(:,10),'r');
  else
    plot(output(:,10),'b');
  end
  hold off;
end

%%
routput = zeros(240,10);
boutput = zeros(240,10);

for trial=1:size(TrialStart,1)
  output = signal(TrialStart(trial):TrialStart(trial)+Fs*length-1,:)/100;
  if (labelRange(trial) == 1)
    routput(:,trial) = output(:,10);
  else
    boutput(:,trial) = output(:,10);
  end
end
hold on
rmean = mean(routput,2);
bmean = mean(boutput,2);
plot(rmean,'r');
plot(bmean,'b');
hold off


