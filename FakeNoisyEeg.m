function output = FakeNoisyEeg(channelRange,nSampleFreq)
channels = size(channelRange,2);

amplitude = 1;
nSines = 100;
SampleRate = 1000;
fMin = 0;
fMax = 100;
t = linspace(0,1,SampleRate);
As = rand(nSines,1)*amplitude;
Fs = linspace(fMin,fMax,nSines)';
Y = zeros(size(t,2),channels);
for channel=channelRange
    Y(:,channel) = sum(As*ones(size(t)).*sin(2*pi*Fs*t));
end

output = Y(100:100+nSampleFreq-1,:);

end