% MC 2017
close all;
clear;
clc;
%options
i_dib=1;					%0 NO /1 YES: show images
i_CM=1;						%0 NO /1 YES: compute confusion matrix
N_classes=10;
K_neig=10;                      %parameter K in knn
%% Selection of transform and dimension
disp(' ')
disp('Select feature selection method')
i_red=input(' No reduction (0), PCA (1), MDA(2) =');
if i_red >0
    disp(' ')
    disp('Enter dimension')
    N_feat=input(' Dim =  ');
else
    N_feat=256;
end
N_dim=16;
%% Read training BD
X_train=[];             % matrix of Nx256 containing all vectors
Labels_train=[];        % labels (samples are initially ordered from class 0 to class 9)

for k=0:N_classes-1
    nombre=sprintf('train%d.txt',k);  
    [data] = textread(nombre,'','delimiter',',');
    %data=round(data);  %optional 
    
    X_train=[X_train;data];
    N_size=size(data);
    Labels_train=[Labels_train;k*ones(N_size(1),1)];
end
clear nombre data k N_size

%% Read test BD
nombre=sprintf('zip.test');
[data] = textread(nombre,'','delimiter',' ');
Labels_test =data(:,1);
X_test=data(:,2:size(data,2));
clear nombre data
%% Transform
if i_red >0
    
    if i_red==1 %PCA
        M_train=mean(X_train);
        X_train2=X_train-ones(length(Labels_train),1)*M_train;
        COEFF = pca(X_train2);
        W=COEFF(:,1:N_feat);
        X_train=X_train2*W;
        X_test=(X_test-ones(length(Labels_test),1)*M_train)*W;
    elseif i_red==2 %MDA
        COEFF= mda_ml(X_train,Labels_train+1,N_classes);
        W=COEFF(:,1:N_feat);
        X_train=X_train*W;
        X_test=X_test*W;
    end

    if i_dib==1
        figure('name','eigenimages')
        for k=1:min(10,N_feat)
            subplot(2,5,k)
            data=W(:,k);
            data=reshape(data,N_dim,N_dim);
            imagesc(data);
            colorbar
            xlabel(k)
        end
        clear k data
    end
end

%% optional: show imagess
if i_dib==1
    figure('name','Images TRAIN')
    for k=0:N_classes-1
        subplot(2,5,k+1)
        ind=find(Labels_train==k);
        N_ale=randi(length(ind));
        data=X_train(ind(N_ale),:);
        if i_red==1 %PCA
            data=W*data'+M_train';
        elseif i_red==2 %MDA
            data=data*pinv(W);
        end
        data=reshape(data,N_dim,N_dim);
        data=data'; 
        imagesc(1-data);
        ylabel(k)
    end
    colormap(gray)
    
    figure('name','Images Test')
    for k=0:N_classes-1
        subplot(2,5,k+1)
        ind=find(Labels_test==k);
        N_ale=randi(length(ind));
        data=X_test(ind(N_ale),:);
        if i_red==1
            data=W*data'+M_train';
        elseif i_red==2
            data=data*pinv(W);
        end
        data=reshape(data,N_dim,N_dim);
        data=data';
        imagesc(1-data);
        ylabel(k)
    end
    colormap(gray)
    clear N_ale k data ind N_ale
end
clear i_dib i_red
%% Create a knn classifier:
knnclass = fitcknn(X_train,Labels_train,'NumNeighbors',K_neig);
knn_out = predict(knnclass,X_train);
knn_Pe_train=sum(Labels_train ~= knn_out)/length(Labels_train);
fprintf(1,' error knn train = %g   \n', knn_Pe_train)
knn_out = predict(knnclass,X_test);
knn_Pe_test=sum(Labels_test ~= knn_out)/length(Labels_test);
fprintf(1,' error knn test = %g   \n', knn_Pe_test)
% Test confusion matrix
if i_CM==1
    CM_knn_test=confusionmat(Labels_test,knn_out)
end
