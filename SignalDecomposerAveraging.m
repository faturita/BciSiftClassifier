% Generates the averages of 8 subjects for the 008-2014 dataset.

% https://www.mathworks.com/matlabcentral/fileexchange/24916-baseline-fit
% https://www.mathworks.com/help/signal/ref/sgolayfilt.html
% https://www.mathworks.com/help/signal/ref/butter.html

% run('/Users/rramele/work/vlfeat/toolbox/vl_setup')
% run('D:\MATLAB\vlfeat-0.9.18\toolbox\vl_setup');
% run('C:/vlfeat/toolbox/vl_setup')
% P300 for ALS patients.

%clear all;

rng(396544);


subjectaverages= cell(0);

subjectartifacts = 0;
subjectnumberofsamples=5;
%for subjectnumberofsamples=12*[10:-1:1]-1
for subject = 1:8
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
siftscale=1.6;  % Determines lamda length [ms] and signal amp [microV]
imagescale=4;    % Para agarrar dos decimales NN.NNNN
siftdescriptordensity=1;
Fs=256;
windowsize=1;
expcode=2400;
% =====================================

data.epoch=zeros(1,4200);

downsize=16;

data.X = notchsignal(data.X, channelRange);

%data.X=downsample(data.X,downsize);
%data.X = decimateaveraging(data.X,channelRange,downsize);
data.X = bandpasseeg(data.X, channelRange,Fs);
data.X = decimatesignal(data.X,channelRange,downsize);
Fs=Fs/downsize;

%drawfft(data.X(:,2)',true,Fs);
         
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
    processedflashes=0;
    for flash=0:119
        % Check wether or not are we going to provide that amount of
        % sample points.
        if (processedflashes>subjectnumberofsamples)
            break;
            %ProcessFlash
            
            % RESET
            %routput=[];
            %boutput=[];

            %artifact=false;
            %bcounter=0;
            %rcounter=0;
            %processedflashes=0;
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
        
        if ((label==2) && (rcounter<2))
            routput = [routput; output];
            rcounter=rcounter+1;
            %bmean=output;
            %GenerateImage
        end
        if ((label==1) && (bcounter<2))
            boutput = [boutput; output];
            bcounter=bcounter+1;
            %bmean=output;
            %GenerateImage
        end
              

    end
    
    if (size(routput,1) >= 2)
        assert( bcounter == rcounter, 'Averages are calculated from different sizes');
    
        assert( size(boutput,1) == size(routput,1), 'Averages are calculated from different sizes.')
    
        assert( (size(routput,1) >= 2 ), 'There arent enough epoch windows to average.');
   
        routput=reshape(routput,[Fs size(routput,1)/Fs 8]);
        boutput=reshape(boutput,[Fs size(boutput,1)/Fs 8]);

        for channel=channelRange
            rmean(:,channel) = mean(routput(:,:,channel),2);
            bmean(:,channel) = mean(boutput(:,:,channel),2);
        end
        figure;
        hold on;
        subplot(3,1,1);
        hold on;
        figure;
        hold on;
        plot(rmean(:,2),'r');
        axis([0 Fs -5 5]);
        subplot(3,1,2);
        hold on;
        plot(bmean(:,2),'b');
        axis([0 Fs -5 5]);
        subplot(3,1,3);
        hold on;
        plot(rmean(:,2),'r');
        plot(bmean(:,2),'b');
        axis([0 Fs -5 5]);
        hold off

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

trainingRange=1:1800;
testRange=1801:epoch;
SignalDecomposerClassification
%SignalDecomposerCrossValidated
subjectACCij(subjectnumberofsamples,subject,:) = ACCij(:);
subjectACCijsigma(subjectnumberofsamples,subject,:) = ACCijsigma(:);
end
%end

%%
for subject=1:8
    rmean = subjectaverages{subject}.rmean;
    bmean = subjectaverages{subject}.bmean;
    
    %[n,m]=size(rmean);
    %rmean=rmean - ones(n,1)*mean(rmean,1);
            
    %[n,m]=size(bmean);
    %bmean=bmean - ones(n,1)*mean(bmean,1);
    
    fig = figure(3);

    subplot(4,2,subject);
    
    hold on;
    Xi = 0:0.1:size(rmean,1);
    Yrmean = pchip(1:size(rmean,1),rmean(:,2),Xi);
    Ybmean = pchip(1:size(rmean,1),bmean(:,2),Xi);
    plot(Xi,Yrmean,'r','LineWidth',2);
    plot(Xi,Ybmean,'b--','LineWidth',2);
    %plot(rmean(:,2),'r');
    %plot(bmean(:,2),'b');
    axis([0 Fs -6 6]);
    set(gca,'XTick', [Fs/4 Fs/2 Fs*3/4 Fs]);
    set(gca,'XTickLabel',{'0.25','.5','0.75','1s'});
    set(gca,'YTick', [-5 0 5]);
    set(gca,'YTickLabel',{'-5 uV','0','5 uV'});
    set(gcf, 'renderer', 'opengl')
    %hx=xlabel('Repetitions');
    %hy=ylabel('Accuracy');
    set(0, 'DefaultAxesFontSize',18);
    text(0.5,4.5,sprintf('Subj %d',subject),'FontWeight','bold');
    %set(hx,'fontSize',20);
    %set(hy,'fontSize',20);
end
legend('Target','NonTarget');
hold off

%%
informedinpaper =   [  0.845  
    0.863    
    0.872    
    0.859    
    0.862    
    0.886    
    0.886    
    0.923 ];

totals = [];
fid = fopen('output.txt','a');
for subject=1:8
    [C,I] = max(subjectACCij(subjectnumberofsamples,subject,:));
    S = subjectACCijsigma(subjectnumberofsamples,subject,I);
    d = subjectACCij(subjectnumberofsamples,subject,2);
    
    totals = [totals ;subject informedinpaper(subject) [ d mean(subjectACCij(subjectnumberofsamples,subject,:)) I C  S]];
    fprintf(fid,'%d     & %6.2f & %6.2f', [ subject informedinpaper(subject) d]);
    fprintf(fid,'& %s', channels{I});
    fprintf(fid,'& %6.2f $\\pm$ %4.2f \\\\\n', [C S]);
end
totals
fclose(fid);

%%
if (graphics)
    processedflashes = 12*[10:-1:1]-1;
    fig = figure
    hold on;
    % samples, subject, channel
    plot(processedflashes,subjectACCij(processedflashes,2,1),'y','LineWidth',2)
    plot(processedflashes,subjectACCij(processedflashes,2,2),'m','LineWidth',2)
    plot(processedflashes,subjectACCij(processedflashes,2,3),'c','LineWidth',2)
    plot(processedflashes,subjectACCij(processedflashes,2,4),'r','LineWidth',2)
    plot(processedflashes,subjectACCij(processedflashes,2,5),'g','LineWidth',2)
    plot(processedflashes,subjectACCij(processedflashes,2,6),'b','LineWidth',2)
    plot(processedflashes,subjectACCij(processedflashes,2,7),'b','LineWidth',2)
    plot(processedflashes,subjectACCij(processedflashes,2,8),'k','LineWidth',2) 
    %title(sprintf('10-fold Cross Validation NBNN'));
    hx=xlabel('Repetitions');
    hy=ylabel('Accuracy');
    axis([1 120 0 1.0]);
    figurehandle=gcf;
    set(findall(figurehandle,'type','text'),'fontSize',14); %'fontWeight','bold');
    set(gca,'YTick', [0 0.8 0.9]);
    set(0, 'DefaultAxesFontSize',24);
    set(hx,'fontSize',20);
    set(hy,'fontSize',20);
    hold off
end

%%
if (0)
    fprintf('Performance falling...');
    performingchannels = [ 2 7 2 8 7 2 7 7 ];
    for subject=1:8
        selectedflashes = [119 59 11];
        performancefall = subjectACCij(selectedflashes,2,performingchannels(subject));

        performancepercentagefall = floor((1-performancefall(3)/performancefall(1))*100);

        fprintf('%d & %s', [subject channels{performingchannels(subject)}]);
        fprintf(' & %6.2f & %6.2f & %6.2f & %d%%\\\\\n', [ performancefall' performancepercentagefall ]);

    end
end


%% Generate the cross validated accuracy for Cz, Pz and for the best performing channel.
if (graphics)
    AccuracyPerChannel = subjectACCij(subjectnumberofsamples,:,2);
    SigmaPerChannel = subjectACCijsigma(subjectnumberofsamples,:,2);
    errorbar(AccuracyPerChannel, SigmaPerChannel,'LineWidth',2);
    %title(sprintf('10-fold Cross Validation NBNN'));
    hx=xlabel('Subject');
    hy=ylabel('Accuracy');
    axis([1 8 0 1.0]);
    figurehandle=gcf;
    set(findall(figurehandle,'type','text'),'fontSize',14); %'fontWeight','bold');
    set(gca,'XTick', [1 2 6 8]);
    set(gca,'XTickLabel',{'S1', 'S2','S6', 'S8'});
    set(gca,'YTick', [0 0.7]);
    set(0, 'DefaultAxesFontSize',24);
    set(hx,'fontSize',20);
    set(hy,'fontSize',20);
end


