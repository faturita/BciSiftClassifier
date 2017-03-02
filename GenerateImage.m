epoch=epoch+1;   
data.epoch(epoch) = (ceil(data.trial(trial)/downsize)+ceil(64/downsize)*flash);
labelRange(epoch) = label;
for channel=channelRange
    image=eegimagescaled(epoch,label,bmean,channel,imagescale,1);
end
