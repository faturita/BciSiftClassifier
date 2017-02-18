epoch=epoch+1;    
labelRange(epoch) = label;
for channel=channelRange
    image=eegimagescaled(epoch,label,bmean,channel,imagescale,1);
end
