clear Performance;

% Parameters ===================
comps=0;graphics=0;
channelRange=7:7
%DbScanRadio=210;
testRange=epochRange;
% ==============================
sM = dlmread('sM.dat');
sMLabel = dlmread('SMLabel.dat');


for DbScanRadio=50:400
% Classify Something based on sM subMatrix, F, testRange, labelRange
for channel=channelRange
        fprintf ('Channel %d -------------\n', channel);
        
        % Check if I have two different clusters!!!!!!!!!!
        
        %M = MM(channel).M;
        %IX = MM(channel).IX;
        
            predicted = [];
            
            expected = labelRange(testRange);
            
            for test=testRange
                DESCRIPTORS =  F(channel, labelRange(test), test).descriptors;
                
                if (comps>0)
                    DESCRIPTORS  =  ((DESCRIPTORS)' * coeff)';
                    DESCRIPTORS=DESCRIPTORS(1:comps,:);
                end
                
                
                Labels = zeros(1,size(DESCRIPTORS,2));
                %SC(test).Cluster = [];
                %for cluster=1:size(DE.C,2)
                    %if (size(DE.C(cluster).M,2)) > 0
                        [IDX,D] = knnsearch(sM',DESCRIPTORS');
                        
                        RADIOS = zeros(1,size(sM,2))+DbScanRadio;
                        
                        IDX2 = [];
                        for d=1:size(D,1)
                            if (D(d)<=RADIOS(IDX(d)))
                                IDX2 = [IDX2 IDX(d)];
                                Labels(d) = sMLabel(IDX(d));
                                %SC(test).Cluster = [SC(test).Cluster [cluster]];
                            end
                        end
                    %end
                %end
                
               
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
                
                %SC(test).Hits = Hits;
                
                fprintf ('+Test %d Class 1: %3d Class 2: %3d \n', test, white,black);
                
                
                if (white>black)
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
Performance(channel,DbScanRadio)=ACC;
end