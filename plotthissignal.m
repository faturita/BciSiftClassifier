epoch=31;
plot((-1)*data.X(data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1):data.trial(floor(epoch/120)+1)+64*(mod(epoch,120)-1)+Fs*windowsize-1,2))
axis([0 256/downsize -30 30]);

