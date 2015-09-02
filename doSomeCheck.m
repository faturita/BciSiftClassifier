DbScanRadio=210;minPts=2;channel=7;graphics=0; comps=0; expcode=45;

Performance=[];
for channel=7:7
    for DbScanRadio=50:300
        fprintf('Channel %10.3f - MinPts %10.3f - Radio: %10.3f\n', channel,minPts, DbScanRadio);
        DE = BciSiftFeatureExtractor(F,expcode,DbScanRadio,minPts,channel,epochRange,labelRange,0,0);
        [ACC, SC] = BciSiftClassifier(F,DE,channel,epochRange,labelRange,0,0);
        Performance(channel, DbScanRadio)= ACC;
    end
end


figure
plot(Performance(channel,:));
title(sprintf('Exp.%d:Channel %10.3f - MinPts %10.3f', expcode, channel, minPts));
xlabel('DbscanRadio')
ylabel('ACC')
axis([0 500 0 1.3]);