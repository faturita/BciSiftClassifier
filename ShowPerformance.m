figure
for channel=1:14
    subplot(7,2,channel);
    plot(Performance(channel,:));
    %title(sprintf('%d', channel));
    %title(sprintf('Exp.%d:Channel %10.3f - MinPts %10.3f', expcode, channel, minPts));
    %xlabel('DbscanRadio')
    %ylabel('ACC')
    axis([0 300 0 1]);
end