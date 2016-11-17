% Descriptor DescriptorDial

% Baseline Corrections

subjectaverages= cell(0);
clear mex;clearvars  -except subject*;close all;clc;

% Clean all the directories where the images are located.
cleanimagedirectory();


subject = 2;
load(sprintf('/Users/rramele/GoogleDrive/BCI.Dataset/008-2014/A%02d.mat',subject));

% NN.NNNNN
% data.X(sample, channel)
% data.y(sample)  --> 0: no, 1:nohit, 2:hit
% data.y_stim(sample) --> 1-12, 1-6 cols, 7-12 rows

%     'Fz'    'Cz'    'Pz'    'Oz'    'P3'    'P4'    'PO7'    'PO8'
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
% Notch filter to the entire signal
wo = 50/(256/2);  bw = wo/35;
[b,a] = iirnotch(wo,bw);

% Band pass filter 
for channel=channelRange
   data.X(:,channel)=filter(b,a,data.X(:,channel)); 
   
   [b,a] = butter(4,10/(Fs/2));
   %freqz(b,a)
   x1 = data.X(:,channel);
   data.X(:,channel) = filter(b,a,x1);

end


trial=1;
flash=0;
Fs=256;
length=1;

epoch=0;
fig = figure;
for trial=1:2
    routput = [];
    boutput = [];
    rands = randperm(120);
    labels = zeros(1,120);
    for flash=0:119
            
        % 64 is the length of 32 stimulus + 32 rest.
        label=data.y(data.trial(trial)+64*flash);
        
        labels(flash+1) = label;
        
    end
    
    rcounter=0;
    bcounter=0;
    artifact=0;
    for flash=0:119
        label=labels(flash+1);
        output = data.X( (data.trial(trial)+64*flash):(data.trial(trial)+64*flash)+Fs*length-1,:);
        
        if (mod(flash,12)==0)
            % Reset Counter
            rcounter=0;
            bcounter=0;
            
            % Artifact rejection.
            iteration = data.X( (data.trial(trial)+64*flash):(data.trial(trial)+64*flash)+64*12-1,:);

            iff = ((abs(iteration)>70));
            ifs = find(iff==1);
            artifact = (size(ifs,1)>1);            
        end
        
        if (artifact)
            subjectartifacts = subjectartifacts + 1;
            continue;
        end
    
        % 64 is the length of 32 stimulus + 32 rest.
        label=labels(flash+1);
        
        output = data.X( (data.trial(trial)+64*flash):(data.trial(trial)+64*flash)+Fs*length-1,:);
        
        %figure;plot(output(:,2));

        baseline = data.X( (data.trial(trial)+64*flash)-51:(data.trial(trial)+64*flash)+Fs*length-1,:);
         
        for channel=channelRange
           %baseline(:,channel) = bf(baseline(:,channel),1:51,'linear');
           %output(:,channel) = baseline(51:51+256-1,channel);
           [n,m]=size(output);
           output=output - ones(n,1)*mean(baseline(1:51-1,:),1);
           
        end
    
        % We are only adding values to the list (zeros are not counted in
        % the averaging)
        if ((label==1) && (rcounter<2))
            routput = [routput; output];
            rcounter=rcounter+1;
        end
        if ((label==2) && (bcounter<2))
            boutput = [boutput; output];
            bcounter=bcounter+1;
        end
        
        epoch = epoch + 1;
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



%% Data Visualization
figure;
subplot(2,2,1);
epoch=230;
plot((-1)*data.X(data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1):data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1)+Fs*length-1,2))
axis([0 256 -30 30]);
subplot(2,2,3);
DisplayDescriptorImageFull(F,epoch,1,2,0);

subplot(2,2,2);
epoch=231;
plot((-1)*data.X(data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1):data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1)+Fs*length-1,2))
axis([0 256 -30 30]);

subplot(2,2,4);
DisplayDescriptorImageFull(F,epoch,2,2,0);

%% Descriptor Dial
for epoch=1:30
    label=labelRange(epoch);
    KS=171;
    channel=2;
    [patternframe, pattern] = PlaceDescriptors(channel,label,epoch, siftscale, siftdescriptordensity,KS);
    %figure;
    %DisplayDescriptorImage(frames,pattern,epoch,label,channel,1);

    pattern = single(pattern);


    dSignal=zeros(1,256);

    KS=1:256;
    [frames, desc] = PlaceDescriptors(channel,label,epoch, siftscale, siftdescriptordensity,KS);

    for i = 1:size(desc,2)
        descriptor = single(desc(:,i));
        dSignal(frames(1,i)) = norm(descriptor-pattern);
    end


    figure1=figure('Position', [100, 100, 1024, 1200]);
    subplot(4,1,1);
    plot(dSignal);
    axis([0 256 0 1000]);
    subplot(4,1,[2,3]);
    DisplayDescriptorImage(patternframe,pattern,epoch,label,channel,1);
    subplot(4,1,4);
    plot((-1)*data.X(data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1):data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1)+Fs*length-1,2))
    axis([0 256 -30 30]);
end

