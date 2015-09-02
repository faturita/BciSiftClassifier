function NEWCLUSTER = HomogenizeCluster(M,Radios,IX,ptsC,cluster,clusterlabel)

% M no tiene repetidos incongruentes: repetidos con diferentes labels
sM = M(:,find(ptsC==cluster));
rads = Radios(find(ptsC==cluster));
sIX = IX(find(ptsC==cluster),:);
sIndx = find(ptsC==cluster);

if (1==1)
    [sC,IM,IC] = unique(sM','rows','stable');

    sM = sM(:,IM);
    rads = rads(IM);
    sIX = sIX(IM,:);
    sIndx = sIndx(IM);
end

% Submatrix M
NEWCLUSTER.M(:,:) = sM(:,:);
% Radios (Moras algorithm): DbScanRadio for everyone.
NEWCLUSTER.Radios = rads;
% Cluster 'cluster' label (homogeneous)
NEWCLUSTER.Label = clusterlabel;
% Index values (from where this descriptor comes from)
NEWCLUSTER.IX(:,:) = sIX(:,:);
% Index pointer to original M matrix.
NEWCLUSTER.Indx = sIndx;

end       
            
            


