    assert( bcounter == rcounter, 'Averages are calculated from different sizes');
    
    assert( size(boutput,1) == size(routput,1), 'Averages are calculated from different sizes.')
    
    assert( (size(routput,1) >= 2 ), 'There arent enough epoch windows to average.');
   

    routput=reshape(routput,[Fs size(routput,1)/Fs 8]);
    boutput=reshape(boutput,[Fs size(boutput,1)/Fs 8]);

    for channel=channelRange
        rmean(:,channel) = mean(routput(:,:,channel),2);
        bmean(:,channel) = mean(boutput(:,:,channel),2);
    end
%     figure;
%     hold on;
%     subplot(3,1,1);
%     ho    figure;
%     hold on;ld on;
%     plot(rmean(:,2),'r');
%     axis([0 Fs -5 5]);
%     subplot(3,1,2);
%     hold on;
%     plot(bmean(:,2),'b');
%     axis([0 Fs -5 5]);
%     subplot(3,1,3);
%     hold on;
%     plot(rmean(:,2),'r');
%     plot(bmean(:,2),'b');
%     axis([0 Fs -5 5]);
%     hold off
    
    subjectaverages{subject}.rmean = rmean;
    subjectaverages{subject}.bmean = bmean;  
    
    epoch=epoch+1;    
    label = 1;
    labelRange(epoch) = label;
    for channel=channelRange
        image=eegimagescaled(epoch,label,bmean,channel,imagescale,1);
    end

    epoch=epoch+1;
    label = 2;
    labelRange(epoch) = label;
    for channel=channelRange
        image=eegimagescaled(epoch,label,rmean,channel,imagescale,1);
    end  
    
    
    routput=[];
    boutput=[];
    
    artifact=false;
    bcounter=0;
    rcounter=0;