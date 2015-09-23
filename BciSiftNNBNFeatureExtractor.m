graphics=0;comps=0;
channel = 7;

%trainingRange=[6:15 21:30];
%testRange=[1:5 16:20];

%trainingRange=[1:10 101:110];
%testRange=[11:100 111:200];

[M1, IX1] = BuildDescriptorMatrix(F,channel,labelRange,find(labelRange(trainingRange)==1));


[M2, IX2] = BuildDescriptorMatrix(F,channel,labelRange,find(labelRange(trainingRange)==2));

DE.C(1).M = M1;
DE.C(1).Label = 1;

DE.C(2).M = M2;
DE.C(2).Label = 2;

DE.CLSTER = [DE.C(1).Label DE.C(2).Label];
