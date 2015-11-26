% This script generates the graphics published here and here.
% It retrieves the results of applying the BciSift classification algorithm
% after applying a 10-Fold CrossValidation procedure, while discriminating
% between Baseline vs Right Hand Imagery.
%
% S.1.T -> Contains all the results of the Training
acs = [];
for subject=1:14
    
    load(sprintf('S.%d.T.mat', subject));
    
    AccuracyPerChannel([5 8 11])'
    
    acs = [acs;[AccuracyPerChannel([5 8 11])']];
    
end

acs

set(0,'DefaultAxesFontSize',12);
bar(1:14,acs);
hx=xlabel('Participant');
hy=ylabel('Accuracy');
axis([0 15 0 1.0]);
figurehandle=gcf;
set(findall(figurehandle,'type','text'),'fontSize',12);
set(gca,'XTick',1:14);
set(gca,'XTickLabel',{'P1','P2','P3','P4','P5','P6','P7','P8','P9','P10','P11','P12','P13','P14'});
set(gca,'YTick',[0 0.5 0.7]);
set(hx,'fontSize',20);
set(hy,'fontSize',20);
legend({'C3','Cz','C4'});
hold on
plot(get(gca,'xlim'),[0.5 0.5]);
plot(get(gca,'xlim'),[0.7 0.7]);
hold off