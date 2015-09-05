% Analizando descriptores buenos para clasificar
DESCS = [];

% Parameters ==================================================
% SC, testRange
% SC(i).Cluster contains the clusters that were matched against
% descriptors.
% For each test image, I have a set of Cluster Ids (in SC(i).Cluster)
% For each cluster (iterating a) I add the set of descriptors that
% form each cluster into DESCS.
% =============================================================

for i=testRange
    Clusters = SC(i).Cluster;
    
    % IX tiene channel, label, epoch, descriptorid  
    for a=1:size(Clusters,2)
        DESCS = [DESCS ;DE.C(Clusters(a)).IX(:,:)];
    end
end

% Lets meassure which descriptor is more important
% to determine clusters
C=unique(DESCS,'rows');
sizes=zeros(size(C,1),1);
for j=1:size(C,1)

    % Find the descriptor id that matches this one.
    L=DESCS(find(DESCS(:,4)==C(j,4)),:);
    
    % And find the descriptor from the same epoch/image.
    L=L(find(L(:,3)==C(j,3)),:);
    
    % Count how many I have.
    sizes(j) = size(L,1);
end

% unique returns the rows in order of repetitions...

sM = [];
sMLabel = [];

for k=1:size(C,1)
    % Pick the most successfull descriptors.
    if (sizes(k)>=1)
        % channel, label, epoch
        %[C(k,1) C(k,2) C(k,3) C(k,4)]
        DisplayDescriptorImage(F(C(k,1),C(k,2),C(k,3)).frames, F(C(k,1),C(k,2),C(k,3)).descriptors, C(k,3),C(k,2),C(k,1),C(k,4)); 
        
        fprintf('Distinguished Descriptor: %2d.%2d.%2d:%3d ', C(k,1),C(k,2),C(k,3),C(k,4));
        
        for i=1:sizes(k)
            fprintf('.');
        end
        
        fprintf('\n');
        
        sM = [sM F(C(k,1),C(k,2),C(k,3)).descriptors(:,C(k,4))];
        sMLabel = [sMLabel C(k,2)];
    end
end

dlmwrite('sM.dat', sM );
dlmwrite('sMLabel.dat', sMLabel);


% 
figure
    plot(sizes);
    title('Repeticiones por descriptor');
    xlabel('N?mero de Indice de Descriptor Unico')
    ylabel('Cantidad de Repeticiones')
    axis([0 600 0 9]);
%     