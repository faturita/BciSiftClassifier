% Parameters ==============================
DbScanRadio=110;minPts=2;channel=7;graphics=1; comps=0; 
%trainingRange=epochRange; %[1:10 16:25];
%testRange=epochRange; %[11:15 26:30];
%trainingRange=[1:75 101:175];
%testRange=[76:100 176:200];
channelRange=1:28;
DbScanRadioRange=210:210;  % Useless!
prompt = 'Experiment? ';
expcode = input(prompt);
%==========================================

Performance=[];
for channel=channelRange
        DE = BciSiftNBNNFeatureExtractor(F,expcode,channel,trainingRange,labelRange,graphics);
        [ACC, ERR, SC] = BciSiftNBNNClassifier(F,DE,channel,testRange,labelRange,0,0);
        Performance(channel, 1)= ACC;
end


if (graphics)
    figure
    plot(Performance(:,1));
    title(sprintf('Exp.%d:NBNN', expcode));
    xlabel('Channel')
    ylabel('ACC')
    axis([0 14 0 1.3]);
end