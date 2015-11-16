function DE = BciSiftNBNNFeatureExtractor(F,expcode,channel,trainingRange,labelRange,graphics)

fprintf('Building Descriptor Matrix M for Channel %d:', channel);
[M1, IX1] = BuildDescriptorMatrix(F,channel,labelRange,trainingRange(find(labelRange(trainingRange)==1)));
fprintf('%d\n', size(M1,2));

% Creating a KDTree.
kdtree1 = vl_kdtreebuild(M1) ;

fprintf('Building Descriptor Matrix M for Channel %d:', channel);
[M2, IX2] = BuildDescriptorMatrix(F,channel,labelRange,trainingRange(find(labelRange(trainingRange)==2)));
fprintf('%d\n', size(M2,2));

% Creating a KDTree.
kdtree2 = vl_kdtreebuild(M2) ;

DE.C(1).M = M1;
DE.C(1).Label = 1;
DE.C(1).IX = IX1;
DE.C(1).KDTree = kdtree1;

DE.C(2).M = M2;
DE.C(2).Label = 2;
DE.C(2).IX = IX2;
DE.C(2).KDTree = kdtree2;

DE.CLSTER = [DE.C(1).Label DE.C(2).Label];

end