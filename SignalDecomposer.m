% Generates the averages of 8 subjects for the 008-2014 dataset.

% https://www.mathworks.com/matlabcentral/fileexchange/24916-baseline-fit
% https://www.mathworks.com/help/signal/ref/sgolayfilt.html
% https://www.mathworks.com/help/signal/ref/butter.html

%run('/Users/rramele/work/vlfeat/toolbox/vl_setup')
% P300 for ALS patients.

subjectaverages= cell(0);
subjectartifacts = 0;
for subject = 1:8
clear mex;clearvars  -except subject*;close all;clc;

% Clean all the directories where the images are located.
cleanimagedirectory();


%subject = 2;
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
imagescale=2;    % Para agarrar dos decimales NN.NNNN
siftscale=3;  % 2 mvoltios y medio.
siftdescriptordensity=1;
Fs=256;
length=1;
expcode=1004;
% =====================================


downsize=8;
Fs=256/downsize;

%drawfft(data.X(:,2)',true,256);
data.X = notchsignal(data.X, channelRange);
%drawfft(data.X(:,2)',true,256);
data.X=downsample(data.X,downsize);
%drawfft(data.X(:,2)',true,Fs);
data.X = bandpasseeg(data.X, channelRange,Fs);         

%drawfft(data.X(:,2)',true,Fs);



epoch=0;

for trial=1:35
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
    for flash=0:119
        label=labels(flash+1);
        if (mod(flash,12)==0)
            iteration = extract(data.X, (floor(data.trial(trial)/downsize)+64/downsize*flash),64/downsize*12);
            bcounter=0;
            rcounter=0;
            artifact=isartifact(iteration);
            
        end
        
        if (artifact)
            subjectartifacts = subjectartifacts+1;
            continue;
        end
        
        
        output = extract(data.X, (floor(data.trial(trial)/downsize)+(64/downsize)*flash),Fs*length);
        % We are only adding values to the list (zeros are not counted in
        % the averaging)
        
        %output2 = data.X( (data.trial(trial)+64*flash):(data.trial(trial)+64*flash)+Fs*length-1,:);
        
        
        [n,m]=size(output);
        output=output - ones(n,1)*mean(output,1);
        
        output = bandpasseeg(output, channelRange,Fs);
        
        
        if ((label==2) && (rcounter<2))
            routput = [routput; output];
            rcounter=rcounter+1;
        end
        if ((label==1) && (bcounter<2))
            boutput = [boutput; output];
            bcounter=bcounter+1;
        end
              

    end

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
trainingRange=1:30;
testRange=31:70;
P300SingleTrialClassification
end

for subject=1:8
    rmean = subjectaverages{subject}.rmean;
    bmean = subjectaverages{subject}.bmean;
    
    [n,m]=size(rmean);
    rmean=rmean - ones(n,1)*mean(rmean,1);
            
    [n,m]=size(bmean);
    bmean=bmean - ones(n,1)*mean(bmean,1);
    
    fig = figure(3);

    subplot(4,2,subject);
    
    hold on;
    plot(rmean(:,2),'r');
    plot(bmean(:,2),'b');
    axis([0 Fs -5 5]);
    set(gca,'XTick', [Fs/4 Fs/2 Fs]);
    set(gca,'XTickLabel',{'0.25','.5','1s'});
    hold off
end
