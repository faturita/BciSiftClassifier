Performance =[]
for minPts=2:30
    for DbScanRadio=100:300
        DE = BciSiftFeatureExtractor(F,45,DbScanRadio,minPts,7,epochRange,labelRange,0,0);
        Performance(minPts,DbScanRadio) = size(DE.CLSTER,2);
    end
end

expcode=45
figure
plot(Performance(10,:));
title(sprintf('Exp.%d:Channel %10.3f - MinPts %10.3f', expcode, channels, minPts));
xlabel('DbscanRadio')
ylabel('ACC')
axis([0 500 0 1.3]);