
%for cluster=1:size(DE.C,2)
%    FTR{cluster}.DD{test} = D;
%    FTR{cluster}.IDX{test} = IDX;
%end



expectedvote = [];

for test=testRange
    
    D1 = FTR{1}.DD{test};

    % La distancia de los descriptores de la imagen 101 a los vecinos cercanos
    % del cluster 2.
    D2 = FTR{2}.DD{test};
    
    voting = [];
    for descrtors=1:size(D1,2)
        voting = [voting ((D1(descrtors) < D2(descrtors))+1)];
    end

    thisvoteexpected = (size(find(voting==1),2) < size(find(voting==2),2))+1;
    
    expectedvote = [expectedvote thisvoteexpected];
    
    figure;
    subplot(2,1,1);bar(D1);
    subplot(2,1,2);bar(D2);
    title(sprintf('Voted %d Expected %d Predicted: %d',thisvoteexpected,RST.expected(1+test-testRange(1)),RST.predicted(1+test-testRange(1))));

end

