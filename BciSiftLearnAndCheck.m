% Parameters ==============================
DbScanRadio=110;minPts=2;channel=7;graphics=1; comps=0; 
%trainingRange=epochRange; %[1:10 16:25];
%testRange=epochRange; %[11:15 26:30];
channelRange=7:7;
DbScanRadioRange=150:230;
prompt = 'Experiment? ';
expcode = input(prompt);
%==========================================

Performance=[];
for channel=channelRange
    for DbScanRadio=DbScanRadioRange
        fprintf('Channel %10.3f - MinPts %d - Radio: %10.3f\n', channel,minPts, DbScanRadio);
        DE = BciSiftFeatureExtractor(F,expcode,DbScanRadio,minPts,channel,trainingRange,labelRange,0,0);
        [ACC, ERR, SC] = BciSiftClassifier(F,DE,channel,testRange,labelRange,0,0);
        Performance(channel, DbScanRadio)= ACC;
    end
end


if (graphics)
    figure
    plot(Performance(channel,:));
    title(sprintf('Exp.%d:Channel %10.3f - MinPts %10.3f', expcode, channel, minPts));
    xlabel('DbscanRadio')
    ylabel('ACC')
    axis([0 500 0 1.3]);
end