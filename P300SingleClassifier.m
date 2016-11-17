%run('/Users/rramele/work/vlfeat/toolbox/vl_setup')
% P300 for ALS patients.
clear mex;clearvars;close all;clc;

% Clean all the directories where the images are located.
cleanimagedirectory();

load('/Users/rramele/GoogleDrive/BCI.Dataset/008-2014/A06.mat');

% NN.NNNNN
% data.X(sample, channel)
% data.y(sample)  --> 0: no, 1:nohit, 2:hit
% data.y_stim(sample) --> 1-12, 1-6 cols, 7-12 rows

%     'Fz'    'Cz'    'Pz'    'Oz'    'P3'    'P4'    'PO7'    'PO8'

% Parameters ==========================
epochRange = 1:4200;
epochRange = 1:600;
channelRange=2:2;
labelRange = zeros(1,4200);
imagescale=1;    % Para agarrar dos decimales NN.NNNN
siftscale=3;  % 2 mvoltios y medio.
siftdescriptordensity=1;
Fs=256;
length=1;
% =====================================

epoch=0;

routput = [];
boutput = [];

for trial=4:4

    for flash=0:119
        
        epoch=epoch+1;
    
        % 64 is the length of 32 stimulus + 32 rest.
        label=data.y(data.trial(trial)+64*flash);
        labelRange(epoch) = label;
    
        output = data.X( (data.trial(trial)+64*flash):(data.trial(trial)+64*flash)+Fs*length-1,:);
    
        %plot(output(:,2));
        
        for channel=channelRange
            output(:,channel) = alphaeegremover(Fs,channel,output);
        end
        
        %figure;plot(output(:,2));

        [n,m]=size(output);
        output=output - ones(n,1)*mean(output,1);
    
        
        if (label==1)
            routput = [routput output(:,2)];
        else
            boutput = [boutput output(:,2)];
        end
        
        for channel=channelRange
            image=eegimagescaled(epoch,label,output,channel,imagescale,1);
        end

    end

end
fdsfds
hold on
rmean = mean(routput,2);
bmean = mean(boutput,2);
plot(rmean,'r');
plot(bmean,'b');
hold off

delta = 0;
for siftscale=1:0.5:10
% Restrict where to put the descriptors but based on the specified density
KS = 64:64+32-1;
KS = 46:110;
%KS = 8*(imagescale):8*(imagescale)+3*(imagescale)*2-1;
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1,KS);
F = LoadDescriptors(labelRange,epochRange,channelRange);

%F = SynthesizeDescriptors(F, labelRange, epochRange, channelRange,3*(imagescale));

% Recordar que testRange tiene que ser de largo igual cantidad de ambas
% clases para que ACC no de mal.


trainingRange=1:4080;
testRange=4080:4200;
trainingRange=1:100;
testRange=101:120;
% Parameters ==============================
graphics=0; comps=0;
prompt = 'Experiment? ';
%expcode = input(prompt);
expcode=132;
%==========================================
ErrorPerChannel = ones(12,1)*0.5;
Pij=zeros(size(channelRange,2),1,1);

delta = delta + 1;

for channel=channelRange

    % --------------------------
    %for channel=channelRange
    fprintf('Channel %d\n', channel);
    DE = BciSiftNBNNFeatureExtractor(F,expcode,channel,trainingRange,labelRange,graphics);
    [ACC, ERR, SC] = BciSiftNBNNClassifier(F,DE,channel,testRange,labelRange,0,0);
    P = SC{1}.TN / (SC{1}.TN+SC{1}.FN);
    Performance(channel,delta) = P;
    Pij(channel,1,1) = ERR;
    Selectivity(channel,1,1) = SC{1}.TP/(SC{1}.TP+SC{1}.FP);
    ErrorPerChannel(channel)=ERR;
    
end
end

hghkjjkh
% Data Visualization
figure;
subplot(2,2,1);
epoch=545;
plot((-1)*data.X(data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1):data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1)+Fs*length-1,2))
axis([0 256 -30 30]);
subplot(2,2,3);
DisplayDescriptorImageFull(F,epoch,1,2,0);

subplot(2,2,2);
epoch=482;
plot((-1)*data.X(data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1):data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1)+Fs*length-1,2))
axis([0 256 -30 30]);

subplot(2,2,4);
DisplayDescriptorImageFull(F,epoch,2,2,0);