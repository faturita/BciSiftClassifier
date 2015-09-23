% run('C:\vlfeat-0.9.18\toolbox\vl_setup')
% BCI descriptors Experiment IV
close all; clear; clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end

% Clean Descriptor Directory
if (exist(sprintf('%s',getdescriptorpath()),'dir'))
    delete(sprintf('%s%s*.dat',getdescriptorpath(),filesep));
end
load(sprintf('%s\\BCICompetitionIIDatasetIV\\sp1s_aa.mat',getdrivepath()));

clab;  % electrode labels.

% Parameters ==========================
epochRange = 1:316;
channelRange=1:28;
labelRange = zeros(1,size(epochRange,2));
imagescale=1;
siftscale=1;
siftdescriptordensity=1;
% =====================================


for epoch=epochRange     % subject

    class=y_train(epoch)+1;   % experiment

    output = x_train(:,:,epoch); 
    
    [n,m]=size(output);
    output=output - ones(n,1)*mean(output,1);
    
    % Signal normalization, eliminates descriptors.
    %output = zscore(output);

    % Do some preprocessing on signals if you want...
    %[coeff, score, latent] = princomp(output);

    %cumsum(latent)./sum(latent)

    %output = score;    
    
    %output = fastica(output');
    
    %output = output';
    
    %output= output(:,14) - output(:,18)
    

    for channel=channelRange
        image=eegimagescaled(epoch,class,output,channel,imagescale);
    end

end

labelRange(:)=y_train(1:size(epochRange,2))+1;
%experimentRange=experimentRange(randperm(size(experimentRange,2)));

% Generate and Save all the descriptors...
%SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
%F = LoadDescriptors(labelRange,epochRange,channelRange);


load(sprintf('%s\\BCICompetitionIIDatasetIV\\sp1s_aa_test.txt',getdrivepath()));

load(sprintf('%s\\BCICompetitionIIDatasetIV\\labels_data_set_iv.txt',getdrivepath()));


labels=zeros(1,100);

for epoch=317:416     % subject

    labelRange(epoch)=labels_data_set_iv(epoch-316)+1;   % experiment

    %output = sp1s_aa_test(epoch,:); 
    %output = vec2mat(output,28);
    
    %a = sp1s_aa_test(1,:);

    %b = reshape(a,50,28);

    output = x_test(:,:,epoch-316);
    

    [n,m]=size(output);
    output=output - ones(n,1)*mean(output,1);

    % Signal Normalization, eliminates descriptors.
    %output = zscore(output);
     
    % Do some preprocessing on signals if you want...
    %[coeff, score, latent] = princomp(output);

    %cumsum(latent)./sum(latent)

    %output = score;        

    %output= output(:,14) - output(:,18);
    
    for channel=channelRange
        image=eegimagescaled(epoch,labelRange(epoch),output,channel,imagescale);
    end

end

epochRange=1:416;
trainingRange=1:316;
testRange=317:416;

% Generate and Save all the descriptors: TrainingRange + TestRange
SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1);
F = LoadDescriptors(labelRange,epochRange,channelRange);
