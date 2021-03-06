rng(396544);


subjectaverages= cell(0);

subjectartifacts = 0;
subjectnumberofsamples=5;
%for subjectnumberofsamples=12*[10:-1:1]-1
%for subject = 8:8
subject=8;
clear mex;clearvars  -except subject*;close all;clc;

% Clean all the directories where the images are located.
cleanimagedirectory();


%load(sprintf('/Users/rramele/GoogleDrive/BCI.Dataset/008-2014/A%02d.mat',subject));
load(sprintf('D:/GoogleDrive/BCI.Dataset/008-2014/A%02d.mat',subject));
%load(sprintf('C:/Users/User/Google Drive/BCI.Dataset/008-2014/A%02d.mat',subject));


% NN.NNNNN
% data.X(sample, channel)
% data.y(sample)  --> 0: no, 1:nohit, 2:hit
% data.y_stim(sample) --> 1-12, 1-6 cols, 7-12 rows

%     'Fz'    'Cz'    'Pz'    'Oz'    'P3'    'P4'    'PO7'    'PO8'

channels={ 'Fz'  ,  'Cz',    'Pz' ,   'Oz'  ,  'P3'  ,  'P4'   , 'PO7'   , 'PO8'};


% Parameters ==========================
epochRange = 1:120*7*5;
channelRange=1:8;
labelRange = zeros(1,4200);
siftscale=3;  % Determines lamda length [ms] and signal amp [microV]
imagescale=2;    % Para agarrar dos decimales NN.NNNN
siftdescriptordensity=1;
Fs=256;
windowsize=1;
expcode=2400;
% =====================================

data.epoch=zeros(1,4200);

downsize=8;

data.oX = data.X;

data.W = drugsignal(Fs,data.X,20,10);
data.W = notchsignal(data.W, channelRange);
data.W = bandpasseeg(data.W, channelRange, Fs);
data.W = decimatesignal(data.W,channelRange,downsize);

data.X = notchsignal(data.X, channelRange);
%data.X=downsample(data.X,downsize);
%data.X = decimateaveraging(data.X,channelRange,downsize);
data.X = bandpasseeg(data.X, channelRange,Fs);
data.X = decimatesignal(data.X,channelRange,downsize);
Fs=Fs/downsize;






%drawfft(data.X(:,2)',true,Fs);
         
%drawfft(data.X(:,2)',true,Fs);     

epoch=0;

for trial=1:5
    routput=[];
    boutput=[];
    labels=zeros(1,120);
    for flash=0:119
        label=data.y(data.trial(trial)+64*flash);
        labels(flash+1) = label;
    end
    
    artifact=false;
    bcounter=0;
    rcounter=0;
    processedflashes=0;
    for flash=0:119
        % Check wether or not are we going to provide that amount of
        % sample points.
        if (processedflashes>subjectnumberofsamples)
            %break;
            %ProcessFlash
            
            routput=[];
            boutput=[];

            artifact=false;
            bcounter=0;
            rcounter=0;
            
            
            processedflashes=0;
        end
        label=labels(flash+1);
        if (mod(flash,12)==0)
            iteration = extract(data.X, (ceil(data.trial(trial)/downsize)+64/downsize*flash),64/downsize*12);
            bcounter=0;
            rcounter=0;
            artifact=isartifact(iteration);        
        end

        if (artifact)
            subjectartifacts = subjectartifacts+1;
            continue;
        end
        
        processedflashes = processedflashes+1;
         
        %output = extract(data.X, (ceil(data.trial(trial)/downsize)+(64/downsize)*flash),Fs*windowsize);
        % We are only adding values to the list (zeros are not counted in
        % the averaging)
        
        %output2 = data.X( (data.trial(trial)+64*flash):(data.trial(trial)+64*flash)+Fs*length-1,:);        
        output = baselineremover(data.X,(ceil(data.trial(trial)/downsize)+ceil(64/downsize)*flash),Fs*windowsize,channelRange,downsize);
 
        [n,m]=size(output);
        output=output - ones(n,1)*mean(output,1);       
        
        if ((label==2) && (rcounter<200))
            routput = [routput; output];
            rcounter=rcounter+1;
            bmean=output;
            GenerateImage
        end
        if ((label==1) && (bcounter<200))
            boutput = [boutput; output];
            bcounter=bcounter+1;
            bmean=output;
            GenerateImage
        end
              

    end
    
    if (false && size(routput,1) >= 2)
        assert( bcounter == rcounter, 'Averages are calculated from different sizes');
    
        assert( size(boutput,1) == size(routput,1), 'Averages are calculated from different sizes.')
    
        assert( (size(routput,1) >= 2 ), 'There arent enough epoch windows to average.');
   
        routput=reshape(routput,[Fs size(routput,1)/Fs 8]);
        boutput=reshape(boutput,[Fs size(boutput,1)/Fs 8]);

        for channel=channelRange
            rmean(:,channel) = mean(routput(:,:,channel),2);
            bmean(:,channel) = mean(boutput(:,:,channel),2);
        end
    %     figure;
    %     hold on;
    %     subplot(3,1,1);
    %     ho    figure;
    %     hold on;ld on;
    %     plot(rmean(:,2),'r');
    %     axis([0 Fs -5 5]);
    %     subplot(3,1,2);
    %     hold on;
    %     plot(bmean(:,2),'b');
    %     axis([0 Fs -5 5]);
    %     subplot(3,1,3);
    %     hold on;
    %     plot(rmean(:,2),'r');
    %     plot(bmean(:,2),'b');
    %     axis([0 Fs -5 5]);
    %     hold off

        subjectaverages{subject}.rmean = rmean;
        subjectaverages{subject}.bmean = bmean;  

        epoch=epoch+1;    
        label = 1;
        labelRange(epoch) = label;
        for channel=channelRange
            image=eegimagescaled(epoch,label,bmean,channel,imagescale,1);
        end

        epoch=epoch+1;
        label = 2;
        labelRange(epoch) = label;
        for channel=channelRange
            image=eegimagescaled(epoch,label,rmean,channel,imagescale,1);
        end  
    end
    
end

trainingRange=1:300;
testRange=310:epoch;

%======================================
epochRange=1:epoch;
labelRange=labelRange(1:epoch);
KS=ceil(0.29*Fs*imagescale):floor(0.29*Fs*imagescale+Fs*imagescale/4-1);
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1,KS);
F = LoadDescriptors(labelRange,epochRange,channelRange);



%% Check Descriptor Distorsion tolerance
for amp=10:2:10
epoch=500;
output = baselineremover(data.X,data.epoch(epoch),Fs*windowsize,channelRange,downsize);
[n,m]=size(output);output=output - ones(n,1)*mean(output,1);    

% Get original signal
[patternimage, patternDOTS] = eegimage(channel,output,imagescale,false);
qKS = 30;
[patternframes, pattern] = PlaceDescriptorsByImage(patternimage, patternDOTS,siftscale, siftdescriptordensity,qKS);

%figure;DisplayDescriptorImageByImage(patternframes,pattern,patternimage,1);

pattern = single(pattern);

T = 1/Fs;                     % Sample time
L = size(output,1);                     % Length of signal
t = (0:L-1)*T;                % Time vector

t = repmat(t,8,1)';
noisyoutput = output+(amp*sin(2*pi*10*t));;


data.W = drugsignal(Fs,data.oX,80,10);
data.W = notchsignal(data.W, channelRange);
data.W = bandpasseeg(data.W, channelRange, Fs);
data.W = decimatesignal(data.W,channelRange,downsize);


output2 = baselineremover(data.W,data.epoch(epoch),Fs*windowsize,channelRange,downsize);
[n,m]=size(output2);output2=output2 - ones(n,1)*mean(output2,1); 


[image, DOTS] = eegimage(channel,output2,imagescale,false);
dSignal=zeros(1,Fs*imagescale)+10000;

qKS=1:Fs*imagescale;
[frames, desc] = PlaceDescriptorsByImage(image,DOTS, siftscale, siftdescriptordensity,qKS);

for i = 1:size(desc,2)
    descriptor = single(desc(:,i));
    dSignal(frames(1,i)) = norm(descriptor-pattern);
end

min(dSignal)

find(dSignal==min(dSignal))

figure1=figure('Position', [100, 100, 1024, 1200]);
subplot(4,2,[1,2]);
plot(dSignal);
title('Euclidean Distance between pattern descriptor and test descriptors (for each t-position).');
axis([0 Fs*imagescale 0 1000]);
subplot(4,2,3);
DisplayDescriptorImageByImage(patternframes,pattern,patternimage,1,true);
subplot(4,2,4);
a = find(dSignal~=0);
DisplayDescriptorImageByImage(frames,desc,image,15,true);    
subplot(4,2,[5,6]);
plot(output(:,channel));
title('Original Signal');
axis([0 Fs -30 30]);
subplot(4,2,[7,8]);
plot(output2(:,channel));
title('Test Signal (noise = 0)');
title(sprintf('Signal contaminated with %10.2f microVolt Amplitude alpha wave',amp));
axis([0 Fs -30 30]);
end
