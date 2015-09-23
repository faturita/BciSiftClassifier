% run('C:\vlfeat-0.9.18\toolbox\vl_setup')
% BCI EPOC Emotiv Drowsiness Data
close all;clear;clc;

% Clean EEG image directory
if (exist(sprintf('%s',getimagepath()),'dir'))
    delete(sprintf('%s%s*.*',getimagepath(),filesep));
end

% Clean Descriptor Directory
if (exist(sprintf('%s',getdescriptorpath()),'dir'))
    delete(sprintf('%s%s*.dat',getdescriptorpath(),filesep));
end


% Parameters ==============
epochRange = 1:30;
channelRange=1:14;
labelRange = [ones(1,size(epochRange,2)/2) ones(1,size(epochRange,2)/2)+1];
imagescale=1;siftscale=1;siftdescriptordensity=12;
% =========================
% Parameters
noisesize=50;
sigma=30;
errorrate=1;
errorrate=0.00001;

channelRange=1:1;
labelRange=[1 1 2 2 1 2 2 1 1 2 1 2 1 1 2 1 2 2 2 1 2 2 1 2 2 1 2 ];
epochRange=1:size(labelRange,2);
dims = 2;
% =============================================


%a=exp( i * 2 * pi / 16 * 1 )

F1=FakeDescriptor([20;150],dims);
F2=FakeDescriptor([150;20],dims);

F3 =FakeDescriptor( [20;20], dims);
F4 =FakeDescriptor( [150;160], dims);

Basal=FakeDescriptor([100;100], dims);


%A = [ones(50,1);ones(50,1)+1];
%shuffle(A);

for channel=channelRange
    for epoch=epochRange
        SYNTHDESCRIPTORS=[];
        
        %z = (100+100i)+80* exp( i * 2 * pi / 16 * randi([1 16],1) );
        
        %x= real(z); y = imag(z);
        
        if (labelRange(epoch) == 1)
            if (rand > errorrate)
                SYNTHDESCRIPTORS = [SYNTHDESCRIPTORS F3+randi([-15 15],dims,1)];
            else
                SYNTHDESCRIPTORS = [SYNTHDESCRIPTORS F4+randi([-15 15],dims,1)];
            end
        else
            if (rand > errorrate)
                SYNTHDESCRIPTORS = [SYNTHDESCRIPTORS F1+randi([-15 15],dims,1)];
            else
                SYNTHDESCRIPTORS = [SYNTHDESCRIPTORS F2+randi([-15 15],dims,1)];
            end        
        end
        
        for kj=1:noisesize
            SYNTHDESCRIPTORS = [SYNTHDESCRIPTORS Basal+randi([-sigma sigma],dims,1)];
        end
        F(channel, labelRange(epoch), epoch).descriptors = SYNTHDESCRIPTORS;
    end
end

trainingRange = [1:10];
testRange = [11:20];

% -------------------------------- FIN