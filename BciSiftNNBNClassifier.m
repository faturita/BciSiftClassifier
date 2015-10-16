% F,DE,featuresize,cluster,channel,testRange 
%function [ACC, SC] = BciSiftNBNNClassifier(F,DE,channel,testRange,labelRange,comps,graphics)
% DE.C(cluster).M Radios Label, tiene la informaci?n de la submatriz del
% cluster.

%load('newdesc.mat');
%featuresize = size(DE.C,2);cluster=featuresize;graphics=0;comps=0;channelRange=7:7


% Parameters =====================
%testRange = [11:15 26:30];
%testRange=epochRange;
% ================================

SC = {};
%figure;
fprintf('Classifying features %d\n', size(DE.CLSTER,2));

% First check if I have at least two differente classes.
if (size(DE.CLSTER,2)<2)
    fprintf('Less than two classifying clusters. \n');
    ACC=0;
elseif (size(DE.C,2)<2)
    fprintf('Just one cluster, no classification \n');
    ACC=0;
else
    %for channel=channelRange
    fprintf ('Channel %d -------------\n', channel);
  
    %M = MM(channel).M;
    %IX = MM(channel).IX;
    
    predicted = [];
    
    expected = labelRange(testRange);
    
    % For each signal window, grab the descriptors and check where they lay
    for test=testRange
        DESCRIPTORS =  F(channel, labelRange(test), test).descriptors;
        
        if (comps>0)
            DESCRIPTORS  =  ((DESCRIPTORS)' * coeff)';
            DESCRIPTORS=DESCRIPTORS(1:comps,:);
        end
        
        
        % Voy a calcular esto: C_hat = arg min SUM || d_i - kNN_c (d_i) ||
        
        SUMSUM = [];
        for cluster=1:size(DE.C,2)
            SUM = 0;
            for descriptor=1:size(DESCRIPTORS,2)
                
                [IDX,D] = knnsearch(DE.C(cluster).M',(DESCRIPTORS(:,descriptor))');
                SUM = SUM + D(1);

            end
            SUMSUM = [SUMSUM SUM];
        end
        [C, I] = min(SUMSUM);
        predicted = [predicted DE.C(I(1)).Label];
        
        if (graphics)
            for i=1:size(DESCRIPTORS',1)
                KL=DESCRIPTORS';
                if (DE.C(I(1)).Label == 1)
                    line(KL(i,1),KL(i,2),'marker','X','color','b',...
                        'markersize',10,'linewidth',2,'linestyle','none');
                elseif (DE.C(I(1)).Label == 2)
                    line(KL(i,1),KL(i,2),'marker','X','color','r',...
                        'markersize',10,'linewidth',2,'linestyle','none');
                end
            end
        end

    end
    
    C=confusionmat(expected, predicted)
    
    %if (C(1,1)+C(2,2) > 65)
    %    error('done');
    %end
    
    if (size(C,1)==2)
        ACC = (C(1,1)+C(2,2)) / size(predicted,2);
        ERR = size(predicted,2) - (C(1,1)+C(2,2));
    else
        ACC = (   C(2,2)+C(3,3)  )  / size(predicted,2)  ;
        ERR = size(predicted,2) - (C(2,2)+C(3,3));
    end    

end
%end

if (graphics)
    title(sprintf('Exp.%d:Clusters  BCI-SIFT PCA %d Comp', expcode,comps));
    xlabel('X')
    ylabel('Y')
end

