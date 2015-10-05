% Parameters ==============================
DbScanRadio=110;minPts=2;channel=7;graphics=1; comps=0; 
%trainingRange=epochRange; %[1:10 16:25];
%testRange=epochRange; %[11:15 26:30];
channelRange=12:12;
DbScanRadioRange=210:210;  % Useless!
prompt = 'Experiment? ';
expcode = input(prompt);
%==========================================

T=40;

for t=1:T

kfolds = fold(10, epochRange);

N = zeros(10,1);

for f=1:10

    trainingRange=defold(kfolds, f);
    testRange=kfolds{f};
    
    % --------------------------
    Performance=[];
    for channel=channelRange
            fprintf('Channel %10.3f - MinPts %d - Radio: %10.3f\n', channel,minPts, DbScanRadio);
            run('BciSiftNNBNFeatureExtractor.m');
            run('BciSiftNNBNClassifier.m');
            Performance(channel, 1)= ACC;
            
            N(f) = ACC;
    end


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

E(t) = sum(N)/size(epochRange,2)/2;

end

e= sum(E)/T;
V = (sum( E - e )^2)  / (T-1);
sigma = sqrt( V );

