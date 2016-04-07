% Near Neighbour Descriptor Analyzis

cluster=2;

L=F;
    
for degradation=1:50
    rept = hist(FTR{cluster}.NN,1:size(DE.C(cluster).M,2));

    %figure;hist(FTR{cluster}.NN,1:size(DE.C(cluster).M,2))

    %figure;hist(rept,2:size(rept,2))

    [C, I] = sort(rept,'descend');

    %figure;plot(C);



    % Delete most relevant descriptors
    %DE.C(cluster).M(:,I(1)) = [];
    %DE.C(cluster).IX(I(1),:) =[];

    for prunning=1:5
        IX = DE.C(cluster).IX(I(prunning),:);
        
        L(IX(1)    , IX(2) , IX(3) ).descriptors(:,IX(4) ) = [];
        L(IX(1)    , IX(2) , IX(3) ).frames(:,IX(4) ) = [];
   end

    for channel=channelRange

        % --------------------------
        Performance=[];
        %for channel=channelRange
        fprintf('Channel %d\n', channel);
        DE = BciSiftNBNNFeatureExtractor(L,expcode,channel,trainingRange,labelRange,graphics);
        [ACC, ERR, RST, FTR] = BciSiftNBNNClassifier(L,DE,channel,testRange,labelRange,0,0);
        Performance(channel, degradation)= ACC;
        Pij(channel,1,1) = ERR;
    end
end
%hist(FTR{2}.NN,1:size(DE.C(2).M,2))