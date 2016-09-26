function output = fakep300(imagescale, class, channelRange, nSampleFreq)


% Ru?do uniforme con varianza 2.
output = rand(nSampleFreq,size(channelRange,2))*0;
output = FakeNoisyEeg(channelRange,nSampleFreq);
output = 10*phasereset.noise(1,nSampleFreq,nSampleFreq)';

Fs = nSampleFreq;             % Sampling frequency (EPOC frequency)
T = 1/Fs;                     % Sample time
L = size(output,1);           % Length of signal
t = (0:L-1)*T;                % Time vector

%x1 = sin(2*pi*40*(1:4000)/1000);

% n = t * f
p300 = [0,0,-5,10,15,30,25,10,5,0,0,0] * 1/3;

if (class == 1)
    % I add a 50 Hz TRASH signal to understand if the FFT is working.
    for ch=channelRange
        %output(:,ch) = (4.0*sin(2*pi*16*t)') + output(:,ch);
        output(floor(nSampleFreq*0.3):floor(nSampleFreq*0.3)+size(p300,2)-1,ch) = p300(:);
    end
    
elseif (class == 2)
    for ch=channelRange
        %output(:,ch) = (8.0*sin(2*pi*16*t)') + output(:,ch) ;
    end
end

end