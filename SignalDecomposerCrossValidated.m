%% Classification
%print(fig,sprintf('%d-p300averagedpersubject%d.png',expcode,subject),'-dpng')
%clear('fig');
delta=1;
epochRange=1:epoch;
labelRange=labelRange(1:epoch);

% Restrict where to put the descriptors but based on the specified density
%assert( 64+min(KS)-siftscale*12/2 >= max(KS), sprintf('%d\n',64+min(KS)-siftscale*12/2))

KS=ceil(0.29*Fs*imagescale):floor(0.29*Fs*imagescale+Fs*imagescale/4-1);

SaveDescriptors(labelRange,epochRange,channelRange,10,siftscale, siftdescriptordensity,1,KS);
F = LoadDescriptors(labelRange,epochRange,channelRange);


% Parameters ==============================
%trainingRange=epochRange; %[1:10 16:25];
%testRange=epochRange; %[11:15 26:30];
%channelRange=1:14;
graphics=1; comps=0;
%==========================================
ErrorPerChannel = ones(size(channelRange,2),1)*0.5;


for channel=channelRange
    T=100;
    KFolds=3;
    E = zeros(T,1);

    for t=1:T

        kfolds = fold(KFolds, epochRange);

        N = zeros(KFolds,1);
        EP = zeros(KFolds,1);

        for f=1:KFolds

            trainingRange=defold(kfolds, f);
            testRange=kfolds{f};

            % --------------------------
            Performance=[];
            %for channel=channelRange
            fprintf('Channel %d\n', channel);
            DE = BciSiftNBNNFeatureExtractor(F,expcode,channel,trainingRange,labelRange,graphics);
            [ACC, ERR, SC] = BciSiftNBNNClassifier(F,DE,channel,testRange,labelRange,0,0);
            P = SC{1}.TN / (SC{1}.TN+SC{1}.FN);
            Performance(channel, delta)= ACC;
            N(f) = ERR;
            EP(f) = ERR/size(testRange,2);

            % -hat -----------------------

        end

        %E(t) = sum(N)/size(epochRange,2);
        E(t) = mean(EP);

    end

    e= sum(E)/T;
    V = (sum((( E - e ).^2)))  / (T-1);

    sigma = sqrt( V );
    ErrorPerChannel(channel)=e;
    SigmaPerChannel(channel)=sigma;
end

AccuracyPerChannel = 1-ErrorPerChannel ;
SigmaPerChannel=SigmaPerChannel.*(1.96/(sqrt(T)));

% This is now the averaged value of error k-fold cross validated.
ACCij=AccuracyPerChannel
ACCijsigma=SigmaPerChannel;


if (graphics)
    figure
    bar(AccuracyPerChannel(channelRange));
    %title(sprintf('Exp.%d:k(%d)-fold Cross Validation NBNN: %d, %1.2f',expcode,KFolds,siftdescriptordensity,siftscale));
    xlabel('Channel')
    ylabel('Accuracy')
    axis([0 size(channelRange,2)+1 0 1.3]);
end


subjectACCij(subjectnumberofsamples,subject,:) = ACCij(:);
subjectACCijsigma(subjectnumberofsamples,subject,:) = ACCijsigma(:);
