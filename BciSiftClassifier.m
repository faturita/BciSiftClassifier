% DE.C(cluster).M Radios Label, tiene la informaci?n de la submatriz del
% cluster.

fprintf('Classifying features %d\n', featuresize);

if (~((exist('DE'))))
    fprintf('No homogeneuos cluster, no classification \n');
    ACC=0.5;
elseif ((featuresize==0))
    fprintf('Just one cluster, no classification \n');
    ACC=0.5;
elseif ((cluster<=1))
    fprintf('Just one cluster, no classification \n');
    ACC=0.5;
else
    for channel=channelRange
        fprintf ('Channel %d -------------\n', channel);
        
        % Check if I have two different clusters!!!!!!!!!!
        
        %M = MM(channel).M;
        %IX = MM(channel).IX;
        
            predicted = [];
            
            %testRange=[11:15 26:30];
            %testRange=[1:5   16:20];
            testRange=epochRange;

            expected = labelRange(testRange);
            
            for test=testRange
                DESCRIPTORS =  F(channel, labelRange(test), test).descriptors;
                
                if (comps>0)
                    DESCRIPTORS  =  ((DESCRIPTORS)' * coeff)';
                    DESCRIPTORS=DESCRIPTORS(1:comps,:);
                end
                
                
                Labels = zeros(1,size(DESCRIPTORS,2));
                SC(test).Cluster = [];
                for cluster=1:size(DE.C,2)
                    if (size(DE.C(cluster).M,2)) > 0
                        [IDX,D] = knnsearch(DE.C(cluster).M',DESCRIPTORS');
                        
                        
                        % IDX contains clusters Ids.
                        % D contains distance to each descriptor to its
                        % cluster center.
                        RADIOS = DE.C(cluster).Radios;
                        
                        IDX2 = [];
                        for d=1:size(D,1)
                            if (D(d)<=RADIOS(IDX(d)))
                                IDX2 = [IDX2 IDX(d)];
                                Labels(d) = DE.C(cluster).Label;
                                SC(test).Cluster = [SC(test).Cluster [cluster]];
                            end
                        end
                    end
                end
                
               
                if (graphics)
                    for i=1:size(DESCRIPTORS',1)
                        KL=DESCRIPTORS';
                        if (Labels(i) == 1)
                            line(KL(i,1),KL(i,2),'marker','X','color','b',...
                                'markersize',10,'linewidth',2,'linestyle','none');
                        elseif (Labels(i) == 2)
                            line(KL(i,1),KL(i,2),'marker','X','color','b',...
                                'markersize',10,'linewidth',2,'linestyle','none');
                        end
                    end
                end
                
                % I do not care about the orders of Labels, I just count them
                Hits  = Labels;
                
                white = size(find(Hits == 1),2);
                black = size(find(Hits == 2),2);
                
                SC(test).Hits = Hits;
                
                fprintf ('+Test %d Class 1: %3d Class 2: %3d \n', test, white,black);
                
                if (black>0)
                    predicted=[predicted 2];
                elseif (white>black)
                    predicted=[predicted 1];
                elseif (white<black)
                    predicted=[predicted 2];
                else
                    predicted=[predicted 0];
                    % Empate-> Tiro una moneda Lo bueno es que no me queda un
                    % tercer estado, complejo de analizar despu?s.
                    %disp('Random');
                    %if (rand > 0.5)
                    %    predicted = [predicted 1];
                    %else
                    %    predicted = [predicted 2];
                    %end
                end
            end
            
            C=confusionmat(expected, predicted)
            
            %if (C(1,1)+C(2,2) > 65)
            %    error('done');
            %end
            
            if (size(C,1)==2)
                ACC = (C(1,1)+C(2,2)) / size(predicted,2);
            else
                ACC = (   C(2,2)+C(3,3)  )  / size(predicted,2)  ;
            end
    end
end

if (graphics)
    title(sprintf('Exp.%d:Clusters Dbscan BCI-SIFT PCA %d Comp', expcode,comps));
    xlabel('X')
    ylabel('Y')
end

