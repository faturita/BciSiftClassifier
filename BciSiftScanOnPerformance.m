clear Performance;

prompt = 'Experiment? ';
expcode = input(prompt)

DbScanRadio=2;
minPts=2;
graphics=0;

% Limitarlo solo a un canal
channelRange=7:7;channels=7;

comps=0;
%for minPts=2:mean(mean(D))
    %for channels=11:14
        channelRange=channels:channels;
        for DbScanRadio=50:400
            fprintf('Channel %10.3f - MinPts %10.3f - Radio: %10.3f\n', channels,minPts, DbScanRadio);
            run('BciSiftFeatureExtractor.m');
            run('BciSiftClassifier.m');
            Performance(channels,DbScanRadio)=ACC;
        end
    
    %end

%for channels=1:14
    figure
    plot(Performance(channels,:));
    title(sprintf('Exp.%d:Channel %10.3f - MinPts %10.3f', expcode, channels, minPts));
    xlabel('DbscanRadio')
    ylabel('ACC')
    axis([0 500 0 1.3]);
%end
    
    
% for channels=1:14
% hold on;colors = {'b','g','y','b','r','c','m'};plot(Performance(channels,:),'color', colors{mod(channels,7)+1});
% title(sprintf('Exp.%d:Channel ALL - MinPts %10.3f', expcode, channels, minPts));
% xlabel('DbscanRadio')
% ylabel('ACC')
% axis([0 500 0 1.3]);
% end
