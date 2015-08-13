clear MM;
clear M;
clear DE;


%DbScanRadio=355;minPts=2;channelRange=7:7;graphics=0;   Ejemplo
%interesante
%DbScanRadio=194;minPts=10;channelRange=7:7;graphics=0;comps=20;   
%DbScanRadio=188;minPts=2;channelRange=7:7;graphics=0;   
% SOLO FUNCIONA PARA UN CANAL.
%DbScanRadio=160;minPts=23;channelRange=7:7;graphics=0; comps=10;

%DbScanRadio=15;minPts=2;channelRange=1:1;graphics=1; comps=2; expcode=5;
%DbScanRadio=160;minPts=2;channelRange=14:14;graphics=0; comps=0; expcode=5;

%DbScanRadio=275;minPts=16;channelRange=14:14;graphics=0; comps=0; expcode=20;

%DbScanRadio=155;minPts=2;channelRange=7:7;graphics=0; comps=0; expcode=40;

%DbScanRadio=250;minPts=2;channelRange=7:7;graphics=0; comps=0; expcode=35;

for channel=channelRange
    
    fprintf ('Channel %d -------------\n', channel);
    
    % M Matriz de Descriptores, IX indices (chan, label, subject, descId)
    %[M, IX] = BuildDescriptorMatrix(F,channel,labelRange,[6:15 21:30]);
    [M, IX] = BuildDescriptorMatrix(F,channel,labelRange,epochRange);
    
    %M = M .* (1/max(max(M)));
    
    if (comps>0)
        % Centered=false es para que no le reste la media de cada variable
        [coeff, score, latent] = pca(M','Centered',false);
        %(cumsum(latent)./sum(latent))'

        % Esto NO ESTA BIEN, HABRIA QUE HACERLO POR CLASE Y REFORMULAR IX
        score = score';
        M=score(1:comps,:);
    end
    
    MM(channel).M = M;
    MM(channel).IX = IX;
    
    %MM(channel).D = squareform(pdist(M'));
end

%graphics = 1;

if (graphics)
    hold on;
end

homocluster=0;

% En el caso de DBSCAN los features los devuelve el propio algoritmo.
featuresize = 4;
%while (featuresize<=6)
for channel=channelRange
    
    fprintf ('Channel %d -------------\n', channel);
    
    % Matriz de descriptores (Dimension, Number of Descritors)
    M = MM(channel).M;
    IX = MM(channel).IX;
    
    Labels = IX(:,2)';
    
    
    if (graphics)
        KL=M';
        gscatter(KL(:,1),KL(:,2),Labels)
        set(legend,'location','best')
        axis([0 200 0 200]);axis([100 600 -300 200]);
        axis equal;
    end
    

    %CheckRepeatedDescriptors(M);
    
    %[Indx, Energy, Cidx] = kmedoids3(M,featuresize);
    %[Indx, Energy, Cidx, Radio, featuresize, P] = kcharacteristics(M,squareform(pdist(M')), Labels,featuresize);

    [Indx, ptsC, CENTROIDS] = dbscan(M, DbScanRadio, minPts);
    Radio=[];
    Cidx=[];
    featuresize = size(CENTROIDS,2);
    
    for index=1:featuresize
        
        sizeofcluster = size(find( ptsC==index )',2);
        
        if (sizeofcluster < minPts)
            error('Cluster has less than minPts points, which is valid according to DBscan but I do not want.');
        end
    end
    
    
    
    %DD = MM(channel).D;
    
    % Calculo de los radios de los clusters con el algoritmo de moras.
    %for i=1:featuresize
    %    CLOUDM = M(:,find(ptsC==i));
    %    CLOUDD = DD(find(ptsC==i),find(ptsC==i));
    
    %    RadiosCluster(i) = moras(CLOUDM,CLOUDD);
    %    %Radios = ones(1,size(M,2))*10;
    %end
    
    for i=1:size(M,2)
        %Some assignments can be zero (no particular cluster)
        if (ptsC(i)~=0)
            Radios(i) = 15;%RadiosCluster(ptsC(i));
            Radios(i) = DbScanRadio;
        else
            Radios(i) = 1;
            Radios(i) = DbScanRadio;
        end
        
    end
    
    % Radios
    % M
    
    
    
    %[C, A] = vl_kmeans(M, featuresize);
    %Radio=[];
    %Cidx=[];
    %CENTROIDS=C;
    
    if ((size(Cidx,2)>1))
        % CENTROIDS es la submatriz de 128xFeatureSize con los descriptores
        % representantes de clase.
        CENTROIDS = M(:,Cidx);
    end
    
    if (graphics)
        KL=CENTROIDS';
        line(KL(:,1),KL(:,2),'marker','<','color','k',...
            'markersize',10,'linewidth',2,'linestyle','none');
        
        
        
        CidxTexts = num2str((1:featuresize)','%d');
        text(KL(:,1), KL(:,2), CidxTexts, 'horizontal','left', 'vertical','bottom')
        
        if (featuresize>2)
            %voronoi(KL(:,1), KL(:,2));
        end
        
        KL = M(:,:)';
        
        for i=1:size(M,2)
            colors = {'b','g','y','b','r','c','m'};
            
            line(KL(i,1),KL(i,2),'marker','.','color',colors{ mod(ptsC(i),7)+1},...
                'markersize',10,'linewidth',2,'linestyle','none');
        end
        
    end

    for clusterpoints=1:size(M,2)
        colors = {'b','g','y','b','r','c','m'};
        if (size(Radios,2)>1)
            
            radio=Radios(clusterpoints);
            
            if (graphics && Radios(clusterpoints)>0)
                h = rectangle('position',[KL(clusterpoints,:) - Radios(clusterpoints),Radios(clusterpoints)*2,Radios(clusterpoints)*2],...
                    'curvature',[1 1]); %,'FaceColor',colors{ptsC(clusterpoints)});
                set(h,'linestyle',':');
            end
        end
        
    end
    
    Classes=ptsC;
    
    % Do Homogeneity analysis
    for cluster=1:featuresize
        
        % Retrieve the labels assosiated with this particular "cluster"
        Hits = Labels(find( Classes==cluster )) ;
        
        white = size(find(Hits == 1),2);
        black = size(find(Hits == 2),2);
        
        p1 = white/(black+white);
        p2 = black/(black+white);
        
        % El Descriptor a eliminar es el contrario
        if (white>black)
            clusterlabel = 1;
        else
            clusterlabel = 2;
        end
        
        % Garantizo en este punto que no estoy perdiendo ningun elemento de
        % ningun cluster.
        fprintf ('+Cluster %3d Class 1: %3d Class 2: %3d Index %10.8f,%10.8f \n', cluster,white,black, p1, p2 );
        
        if ((white+black) <= 1)
            fprintf ('Single cluster, discarted\n');
            continue;
        end
        
        if (  p1 <= 0.25 || p1 >= 0.75 )
            fprintf('Homogeneous cluster...\n');
            homocluster=homocluster+1;
            DE.C(cluster).M(:,:) = M(:,find(ptsC==cluster));
            DE.C(cluster).Radios = Radios(find(ptsC==cluster));
            DE.C(cluster).Label = clusterlabel;
        end
    end
end

% Este Script Produce DE.C que tiene clusters homogeneos que se pueden usar
% para clasificar. FUNCIONAN PARA UN SOLO CANAL POR VEZ.