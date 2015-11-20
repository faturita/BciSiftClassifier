for subject=1:14
   load(sprintf('S.%d.T.1.mat',subject)); 
  
   ACCsij(subject,:) = ACCij(:,1,1);
    
   acu5(subject) = ACCij(5,1,1);
   acu8(subject) = ACCij(8,1,1);
   acu11(subject) = ACCij(11,1,1);
end
fdsfs
    set(0, 'DefaultAxesFontSize',15);
    bar(1:14,ACCsij(:,[5 8 11]));
    hx=xlabel('Participant');
    hy=ylabel('Accuracy');
    axis([0 15 0 1.0]);
    figurehandle=gcf;
    set(findall(figurehandle,'type','text'),'fontSize',14); %'fontWeight','bold');
    set(gca,'XTick', 1:14);
    set(gca,'XTickLabel',{'P1', 'P2','P3', 'P4', 'P5','P6','P7','P8','P9','P10','P11','P12','P13','P14'});
    set(gca,'YTick', [0 0.5 0.7]);
    set(hx,'fontSize',20);
    set(hy,'fontSize',20);
    legend({'C3','Cz','C4'});
    hold on
    plot(get(gca,'xlim'),[0.5 0.5]);
    plot(get(gca,'xlim'),[0.7 0.7]);
    hold off
    