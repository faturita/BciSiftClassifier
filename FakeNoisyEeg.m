function output = FakeNoisyEeg(amplitude,channelRange,nSampleFreq)
channels = size(channelRange,2);

SampleRate = 1000;
t = linspace(0,1,SampleRate);
Y = zeros(size(t,2),channels);

for channel=channelRange
    nSines = 100;

    fMin = 0;
    fMax = 100;

    As = rand(nSines,1)*amplitude;
    Fs = linspace(fMin,fMax,nSines)';


    Y(:,channel) = sum(As*ones(size(t)).*sin(2*pi*Fs*t));
end

output = zeros(nSampleFreq, size(channelRange,2));

for channel=channelRange
    output(:,channel) = Y(100:100+nSampleFreq-1,channel);
end

end