function DE = BciSiftNBNNFeatureExtractor(F,expcode,channel,trainingRange,labelRange,graphics)

%channel = 7;

%trainingRange=[6:15 21:30];
%testRange=[1:5 16:20];

%trainingRange=[1:10 101:110];
%testRange=[11:100 111:200];

fprintf('Building Descriptor Matrix M for Channel %d:', channel);
[M1, IX1] = BuildDescriptorMatrix(F,channel,labelRange,trainingRange(find(labelRange(trainingRange)==1)));
fprintf('%d\n', size(M1,2));

fprintf('Building Descriptor Matrix M for Channel %d:', channel);
[M2, IX2] = BuildDescriptorMatrix(F,channel,labelRange,trainingRange(find(labelRange(trainingRange)==2)));
fprintf('%d\n', size(M2,2));

DE.C(1).M = M1;
DE.C(1).Label = 1;
DE.C(1).IX = IX1;

DE.C(2).M = M2;
DE.C(2).Label = 2;
DE.C(2).IX = IX2;

DE.CLSTER = [DE.C(1).Label DE.C(2).Label];

end