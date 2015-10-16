% Parameters ==============================
DbScanRadio=1;minPts=2;channel=1;graphics=1; comps=0; 
%trainingRange=epochRange; %[1:10 16:25];
%testRange=epochRange; %[11:15 26:30];
channelRange=7:7;
DbScanRadioRange=100:300;
prompt = 'Experiment? ';
expcode = input(prompt);
%==========================================

Performance=[];
for minPts=6:6
    for DbScanRadio=DbScanRadioRange
        fprintf('Channel %d - MinPts %d - Radio: %10.3f\n', channel,minPts, DbScanRadio);
        [M, IX] = BuildDescriptorMatrix(F,channel,labelRange,trainingRange);
        [Indx, ptsC, CENTROIDS] = dbscan(M, DbScanRadio, minPts);
        Radio=[];
        Cidx=[];
        
        Labels = IX(:,2)';
        
        Classes=ptsC;
        homocluster=0;

        featuresize = size(CENTROIDS,2); 
                
        % Do Homogeneity analysis
        for cluster=1:featuresize

            % Retrieve the labels assosiated with this particular "cluster"
            Hits = Labels(find( Classes==cluster )) ;

            white = size(find(Hits == 1),2);
            black = size(find(Hits == 2),2);

            p1 = white/(black+white);
            p2 = black/(black+white);

            % El Descriptor a eliminar es el contrario
            if (white>black)
                clusterlabel = 1;
            else
                clusterlabel = 2;
            end

            % Garantizo en este punto que no estoy perdiendo ningun elemento de
            % ningun cluster.
            fprintf ('+Cluster %3d Class 1: %3d Class 2: %3d Index %10.8f,%10.8f \t', cluster,white,black, p1, p2 );

            if ((white+black) <= 1)
                fprintf ('Single cluster, discarted\n');
                continue;
            end

            if (  p1 <= 0.25 || p1 >= 0.75 )
                fprintf('Homogeneous %d \n', clusterlabel);
                homocluster=homocluster+1;
            else
                fprintf('Discarted!\n');
            end
        end        
        
        
        Performance2(minPts, DbScanRadio) = homocluster;
        Performance(minPts,DbScanRadio)=featuresize;
    end
end


if (1==1)
    figure
    hold on
    plot(Performance(minPts,:),'b');
    title(sprintf('Exp.%d:Channel %d - MinPts %10.3f', expcode, channel, minPts));
    xlabel('DbscanRadio')
    ylabel('#Clusters')
    axis([120 320 0 150]);
    
    
    plot(Performance(minPts,:)-Performance2(minPts,:),'g');
    title(sprintf('Exp.%d:Channel %d- MinPts %10.3f', expcode, channel, minPts));
   
    plot(Performance2(minPts,:),'r');
    title(sprintf('Exp.%d:Channel %d- MinPts %10.3f', expcode, channel, minPts));    
    
    axis([120 320 0 150]);
   
    
    plot(Performance(minPts,:)-Performance2(minPts,:),'g');
    title(sprintf('Exp.%d:Channel %10.3f - MinPts %10.3f', expcode, channel, minPts));
    xlabel('DbscanRadio')
    ylabel('#Clusters')
    axis([120 320 0 150]);
    legend('Nonhomogeneous','Homogeneous','Difference');
    hold off
end

K = minPts;
D = pdist2(M',M','euclidean','Smallest',K);
kdist = D(K,:);
kdistsorted = sort(kdist);
title(sprintf('k-Dist-Exp.%d:Channel %d - MinPts %10.3f', expcode, channel, minPts));
figure;plot(kdistsorted)

%filter=fspecial('gaussian',[200 1],1);
x=-10:0.1:10;
filter = gaussmf(x,[1 0]);
kdistdiff = diff(kdistsorted);
kdistdiff = conv(kdistdiff,filter,'same');
title(sprintf('(k-Dist)-Exp.%d:Channel %d - MinPts %10.3f', expcode, channel, minPts));
figure;plot(kdistdiff);

