function output = fakep300(imagescale, class, channelRange, nSampleFreq)


% Ru?do uniforme con varianza 2.
output = rand(nSampleFreq,size(channelRange,2))*0;
output = FakeNoisyEeg(8,channelRange,nSampleFreq);
%output = 10*phasereset.noise(1,nSampleFreq,nSampleFreq)';

Fs = nSampleFreq;             % Sampling frequency (EPOC frequency)
T = 1/Fs;                     % Sample time
L = size(output,1);           % Length of signal
t = (0:L-1)*T;                % Time vector



%x1 = sin(2*pi*40*(1:4000)/1000);

lambda = 49;

% n = t * f
p300 = [0,0,-5,10,15,30,25,10,5,0,0,0] * 1/3;


p300 = [-4,+1,+2,+5,+3,-1,+3,+5,+8,+12,+15,+10,+5,0,1,-1,0];

p300 = interp1(1:size(p300,2),p300,1:size(p300,2)/lambda:size(p300,2));


if (class == 2)
    % I add a 50 Hz TRASH signal to understand if the FFT is working.
    for ch=channelRange
        pos = floor(nSampleFreq*0.3)+randi(20,1,10)-10;
        %output(:,ch) = (4.0*sin(2*pi*16*t)') + output(:,ch);
        output(pos:pos+size(p300,2)-1,ch) = p300(:) + output(pos:pos+size(p300,2)-1,ch);
    end
    
elseif (class == 1)
    for ch=channelRange
        %output(:,ch) = (8.0*sin(2*pi*16*t)') + output(:,ch) ;
    end
end
assert( size(output,2) ~= nSampleFreq );
end