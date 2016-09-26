function [frames, descriptors] = PlaceDescriptor(channel, label, epoch, psiftscale, SAMPLELOCS)

global DOTS;

verbose=GetParameter('verbose');

file = sprintf('e.%d.l.%d.c.%d.tif',epoch,label,channel);

if (verbose) fprintf ('Image File %s\n', file); end

I = imread(sprintf('%s%s',getimagepath(),file));
%I= double(rgb2gray(I)/256);
I = single(I);


FC = [];
width=size(I,2);

% PARAMETROS IMPORTANTES
siftscale=psiftscale;
ssize = 1;

iterator=1;
sampleloc=1;
i=1;
while (i<=size(DOTS(epoch,channel).XX,1))
    if ((DOTS(epoch,channel).YY(i)-siftscale*6)>0 &&  (DOTS(epoch,channel).YY(i)+siftscale*6)<=width) 

        %fc = [DOTS(epoch,channel).YY(i);DOTS(epoch,channel).XX(i);siftscale;0];

        if (DOTS(epoch,channel).YY(i)==SAMPLELOCS(sampleloc))
            fc = [DOTS(epoch,channel).YY(i);DOTS(epoch,channel).XX(i);siftscale;0];

            %fc = [k;75;2;0];

            FC = [FC fc];
            iterator=ssize;
            sampleloc=sampleloc+1;
        end

    end
    i=i+iterator;
    if (size(FC,2)>=size(SAMPLELOCS,2))
        break;
    end
end


%[frames, descriptors] = vl_sift(I,'frames',FC,'floatdescriptors','verbose','verbose','verbose','verbose');

[frames, descriptors] = vl_sift(I,'frames',FC,'verbose','verbose','verbose','verbose');


end




