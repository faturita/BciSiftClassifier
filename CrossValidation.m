% Parameters ==============================
DbScanRadio=210;minPts=2;channel=7;graphics=0; comps=0;
%trainingRange=epochRange; %[1:10 16:25];
%testRange=epochRange; %[11:15 26:30];
channelRange=1:14;
graphics=0; comps=0;
prompt = 'Experiment? ';
%expcode = input(prompt);
expcode=132;
%==========================================
ErrorPerChannel = ones(12,1)*0.5;


for channel=channelRange
    T=3;
    KFolds=3;
    E = zeros(T,1);

    for t=1:T

        kfolds = fold(KFolds, epochRange);

        N = zeros(KFolds,1);

        for f=1:KFolds

            trainingRange=defold(kfolds, f);
            testRange=kfolds{f};

            % --------------------------
            Performance=[];
            %for channel=channelRange
            fprintf('Channel %d\n', channel);
            DE = BciSiftNBNNFeatureExtractor(F,expcode,channel,trainingRange,labelRange,graphics);
            [ACC, ERR, SC] = BciSiftNBNNClassifier(F,DE,channel,testRange,labelRange,0,0);
            Performance(channel, 1)= ACC;
            N(f) = ERR;

            %fprintf('Channel %10.3f - MinPts %d - Radio: %10.3f\n', channel,minPts, DbScanRadio);
            %DE = BciSiftFeatureExtractor(F,expcode,DbScanRadio,minPts,channel,trainingRange,labelRange,0,0);
            %[ACC, ERR, SC] = BciSiftClassifier(F,DE,channel,testRange,labelRange,0,0);
            %Performance(channel, DbScanRadio)= ACC;

            %N(f) = ERR;
            %ERR
            %end


            if (graphics)
                figure
                plot(Performance(channel,:));
                title(sprintf('Exp.%d:Channel %10.3f - MinPts %10.3f', expcode, channel, minPts));
                xlabel('DbscanRadio')
                ylabel('ACC')
                axis([0 500 0 1.3]);
            end

            % -hat -----------------------

        end

        E(t) = sum(N)/size(epochRange,2);

    end

    e= sum(E)/T;
    V = (sum((( E - e ).^2)))  / (T-1);
    sigma = sqrt( V );
    ErrorPerChannel(channel)=e;
    SigmaPerChannel(channel)=sigma;
end

SigmaPerChannel=SigmaPerChannel.*(1.96/(sqrt(T)));

if (graphics)
    figure
    bar(ErrorPerChannel(channelRange));
    title(sprintf('Exp.%d:k(%d)-fold Cross Validation NBNN: %d, %1.2f',expcode,KFolds,siftdescriptordensity,siftscale));
    xlabel('Channel')
    ylabel('Error')
    axis([0 size(channelRange,2)+1 0 1.3]);
end
