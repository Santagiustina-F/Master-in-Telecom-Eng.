%% ML
% LAB 4, BD: SPAM, Classifier: SVM
% April 2016, MC
clear
close all
clc

i_plot=1;                               % 1 plot BD
i_lineal=1;                             % Linear Classifier
i_gauss=1;                              % Gaussian Kernel Classifier

%% Loading SPAM Database
% load dataspam.txt -ascii
load dataspam
Labs=dataspam(:,end);
N_feat=size(dataspam,2)-1;
X=dataspam(:,1:57);
N_datos=length(Labs);

%% Scatter plot
if i_plot==1
    figure('name','Scatter PLOT of signs')
    X2=X(:,49:54);
    gplotmatrix(X2,X2,Labs)
    zoom on
    clear X2
end
drawnow
clear i_plot

%% Binary quantization of features
X=X(:,1:54);
A=find(X>0);
X(A)=ones(size(A));

%% Generation of Training (60 %), Validation (20%) and Test (20%) sets
% Randomize vectors
indexperm=randperm(N_datos);
X=X(indexperm,:);
Labs=Labs(indexperm);

% Identify one vector to compute probabilities (section 4.3)
V_analisis=X(N_datos,:);
Lab_analisis=Labs(N_datos)
N_datos=N_datos-1;
X=X(1:N_datos,:);
Labs=Labs(1:N_datos);

% Generation of Train, Validation and Test sets
N_train=round(0.6*N_datos);
N_val=round(0.8*N_datos)-N_train;
N_test=N_datos-N_train-N_val;

% Train
X_train=X(1:N_train,:);
Labs_train=Labs(1:N_train);

% Validation
X_val=X(N_train+1:N_train+N_val,:);
Labs_val=Labs(N_train+1:N_train+N_val);

% Test
X_test=X(N_train+N_val+1:N_datos,:);
Labs_test=Labs(N_train+N_val+1:N_datos);

clear indexperm
%% Linear classifier
if i_lineal ==1
    P = 0.1;
    Linear_model = fitcsvm(X_train, Labs_train, 'BoxConstraint',P);
    fprintf(1,'\n Linear SVM classifier\n')
    Linear_out = predict(Linear_model, X_train);
    Err_train=sum(Linear_out~=Labs_train)/length(Labs_train);
    fprintf(1,'train error = %g   \n', Err_train)
    Linear_out = predict(Linear_model, X_test);
    Err_test=sum(Linear_out~=Labs_test)/length(Labs_test);
    fprintf(1,'test error = %g   \n', Err_test)
    fprintf(1,'\n  \n  ')
    % Test confusion matrix
    CM_Linear_test=confusionmat(Labs_test,Linear_out)
    clear Err_train Err_test Linear_out
end
clear i_lineal

%% Non-linear classifier, gaussian kernel
if i_gauss ==1
    P = 0.1;
    h=1;
    Gauss_model = fitcsvm(X_train, Labs_train, 'BoxConstraint',P,...
        'KernelFunction','RBF','KernelScale',h);
    fprintf(1,'\n Gaussian Kernel Classifier\n')
    Gauss_out = predict(Gauss_model, X_train);
    Err_train=sum(Gauss_out~=Labs_train)/length(Labs_train);
    fprintf(1,'train error = %g   \n', Err_train)
    Gauss_out = predict(Gauss_model, X_test);
    Err_test=sum(Gauss_out~=Labs_test)/length(Labs_test);
    fprintf(1,'test error = %g   \n', Err_test)
    fprintf(1,'\n  \n  ')
    % Test confusion matrix
    CM_Gauss_test=confusionmat(Labs_test,Gauss_out)
    clear Err_train Err_test Gauss_out
end
clear i_gauss