function cls = WhichCluster(DE,SC,testRange, channel,label, epoch, descriptorId)

cls = 0;

for cq=1:size(DE.C,2)
    ISX = DE.C(cq).IX(:,:);
    for gg = 1:size(ISX,1)
        if ( ISX(gg,1) == channel && ISX(gg,2) == label && ISX(gg,3) == epoch && ISX(gg,4) == descriptorId )
            if (cls ~= 0)
                error('Descriptor belongs to two clusters!');
            else
                cls = cq;
            end
        end
    end
end

as = 0;
BLCK = [];
for test=testRange
    a = size(find(SC(test).Cluster==2),2);
    as = as + a;
    if (a>0)
        BLCK = [BLCK test];
    end
end

BLCK

end



