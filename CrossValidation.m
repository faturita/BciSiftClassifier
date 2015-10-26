% Parameters ==============================
DbScanRadio=210;minPts=2;channel=7;graphics=0; comps=0;
%trainingRange=epochRange; %[1:10 16:25];
%testRange=epochRange; %[11:15 26:30];
channelRange=1:15;
DbScanRadioRange=210:210;  % Useless!
prompt = 'Experiment? ';
%expcode = input(prompt);
expcode=880;
%==========================================

for channel=channelRange
    T=1;
    KFolds=10;
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
            fprintf('Channel %d - MinPts %d - Radio: %10.3f\n', channel,minPts, DbScanRadio);
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
            
            % ------------------------
            
        end
        
        E(t) = sum(N)/size(epochRange,2);
        
    end
    
    e= sum(E)/T;
    V = (sum( E - e )^2)  / (T-1);
    sigma = sqrt( V );
    ErrorPerChannel(channel)=e;
end

if (graphics)
    figure
    plot(ErrorPerChannel);
    title(sprintf('Exp.%d:k-fold Cross Validation NBNN',expcode));
    xlabel('Channel')
    ylabel('Error')
    axis([0 16 0 1.3]);
end
