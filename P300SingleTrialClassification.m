% Script: P300SingleTrialClassification.m

% Process P300 as is traditionally done, by averaging.

%run('/Users/rramele/work/vlfeat/toolbox/vl_setup')
% P300 for ALS patients.
%for subject = 1:8
clear mex;clearvars  -except subject;close all;clc;

% Clean all the directories where the images are located.
cleanimagedirectory();

subject = 3;
load(sprintf('/Users/rramele/GoogleDrive/BCI.Dataset/008-2014/A%02d.mat',subject));

% NN.NNNNN
% data.X(sample, channel)
% data.y(sample)  --> 0: no, 1:nohit, 2:hit
% data.y_stim(sample) --> 1-12, 1-6 cols, 7-12 rows

%     'Fz'    'Cz'    'Pz'    'Oz'    'P3'    'P4'    'PO7'    'PO8'

% Parameters ==========================
epochRange = 1:4200;
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
fig = figure;
for trial=1:35
    routput = [];
    boutput = [];
    rands = randperm(120);
    labels = zeros(1,120);
    for flash=0:119
            
        % 64 is the length of 32 stimulus + 32 rest.
        label=data.y(data.trial(trial)+64*flash);
        
        labels(flash+1) = label;
        
    end
    
    for flash=0:119
        label=labels((flash+1));
        output = data.X( (data.trial(trial)+64*flash):(data.trial(trial)+64*flash)+Fs*length-1,:);

        %output = output*10;
        %plot(output(:,2));
        
        %for channel=channelRange
        %    output(:,channel) = alphaeegremover(Fs,channel,output);
        %end
        
        %figure;plot(output(:,2));

        [n,m]=size(output);
        output=output - ones(n,1)*mean(output,1);
        
        % We are only adding values to the list (zeros are not counted in
        % the averaging)
        if ((label==1) && (size(routput,1)/256)<20)
            routput = [routput; output];
        end
        if ((label==2) && (size(boutput,1)/256)<20)
            boutput = [boutput; output];
        end
                           
    end
    routput=reshape(routput,[256 size(routput,1)/256 8]);
    boutput=reshape(boutput,[256 size(boutput,1)/256 8]);
    fig = figure(1);
    hold on
    
    for channel=channelRange
        rmean(:,channel) = mean(routput(:,:,channel),2);
        bmean(:,channel) = mean(boutput(:,:,channel),2);
    end
    subplot(2,1,1);
    hold on;
    plot(rmean(:,2),'r');
    axis([0 256 -100 100]);
    subplot(2,1,2);
    hold on;
    plot(bmean(:,2),'b');
    axis([0 256 -100 100]);
    hold off
    
    epoch=epoch+1;    
    label = 1;
    labelRange(epoch) = label;
    for channel=channelRange
        image=eegimagescaled(epoch,label,rmean,channel,imagescale,1);
    end
    
    epoch=epoch+1;
    label = 2;
    labelRange(epoch) = label;
    for channel=channelRange
        image=eegimagescaled(epoch,label,bmean,channel,imagescale,1);
    end    

end

print(fig,sprintf('%d-p300averagedpersubject%d.png',expcode,subject),'-dpng')
clear('fig');
delta=1;
epochRange=1:epoch;
labelRange=labelRange(1:epoch);

% Restrict where to put the descriptors but based on the specified density
KS = 64:64+32-1;
KS = 46:110;
KS = 93:146;
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


trainingRange=1:15;
testRange=16:35;
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

AccuracyPerChannel = 1-ErrorPerChannel;
graphics = 1;
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

hghkjjkh
% Data Visualization
figure;
subplot(2,2,1);
epoch=1;
plot((-1)*data.X(data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1):data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1)+Fs*length-1,2))
axis([0 256 -30 30]);
subplot(2,2,3);
DisplayDescriptorImageFull(F,epoch,1,2,0);

subplot(2,2,2);
epoch=2;
plot((-1)*data.X(data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1):data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1)+Fs*length-1,2))
axis([0 256 -30 30]);

subplot(2,2,4);
DisplayDescriptorImageFull(F,epoch,2,2,0);