%% ML
% LAB 4, BD: SPAM, Classifier: SVM
% April 2016, MC
clear
close all
clc
 
%% Loading SPAM Database
% load dataspam.txt -ascii
load dataspam
Labs=dataspam(:,end);
N_feat=size(dataspam,2)-1;
X=dataspam(:,1:57);
N_datos=length(Labs);
 

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

%% Non-linear classifier, gaussian kernel
P1 = 0.1:0.1:5;
h1 = [1,2.5,10,25,100];
err_train = zeros(length(P1),length(h1));
err_val = zeros(length(P1),length(h1));
 
best_P = 0;
best_h = 0;
min_val = realmax;
 
for i = 1:length(P1)
    for j = 1:length(h1)
        P = P1(i);
        h=h1(j);
        Gauss_model = fitcsvm(X_train, Labs_train, 'BoxConstraint',P,...
            'KernelFunction','RBF','KernelScale',h);
        Gauss_out = predict(Gauss_model, X_train);
        err_train(i,j)=sum(Gauss_out~=Labs_train)/length(Labs_train);
        Gauss_out = predict(Gauss_model, X_val);
        err_val(i,j)=sum(Gauss_out~=Labs_val)/length(Labs_val);
        % Test confusion matrix
        %CM_Gauss_val=confusionmat(Labs_val,Gauss_out)
        if err_val(i,j)<min_val
           min_val = err_val(i,j);
           best_P = P1(i);
           best_h = h1(j);
        end
    end
end
%%
P2 = repmat(P1,length(h1),1);
h2 = repmat(h1',1,length(P1));
figure
plot3(P2',h2',err_train)
xlabel('P');
ylabel('h');
zlabel('training error')
 
figure
plot3(P2',h2',err_val)
xlabel('P');
ylabel('h');
zlabel('validation error')

%% Keep the best classifier and use it to make predictions on the test set
Gauss_model = fitcsvm(X_train, Labs_train, 'BoxConstraint',best_P,...
            'KernelFunction','RBF','KernelScale',best_h);
        Gauss_out = predict(Gauss_model, X_test);
CM_Gauss_test=confusionmat(Labs_test,Gauss_out)

%% Metrics of interest
CM = [556 23 ; 29 312]%=CM_Gauss_test;
error = (CM(1,2)+CM(2,1))/(CM(1,1)+CM(1,2)+CM(2,1)+CM(2,2));
accuracy = (CM(1,1)+CM(2,2))/(CM(1,1)+CM(1,2)+CM(2,1)+CM(2,2));
precision = CM(2,2)/(CM(2,2)+CM(1,2)); %modified
recall = CM(2,2)/(CM(2,2)+CM(2,1)); %modified
specificity = CM(1,1)/(CM(1,1)+CM(1,2)); %modified
Fscore = 2*precision*recall/(precision+recall);

%% Analysis of the classifier reliability


%Prior_SPAM = sum(Labs_test == ones(length(Labs_test),1))/length(Labs_test) %label 1 correspond to spam, 0 to non-spam
Prior_SPAM = (CM(2,1)+CM(2,2))/(CM(1,1)+CM(1,2)+CM(2,1)+CM(2,2))
Prior_MAIL = 1 - Prior_SPAM

V_predicted = predict(Gauss_model, V_analisis)
if (V_predicted == 0) 
    'Classified as non-SPAM' 
else
    'Classified as SPAM'
end
if (V_predicted == Lab_analisis) 
    'Good prediction' 
else
    'Wrong prediction'
end

if V_analisis(1)
    'Contains the word make'
end
if V_analisis(2)
    'Contains the word address'
end

P_classifyAsSPAM = (CM(1,2)+CM(2,2))/(CM(1,1)+CM(1,2)+CM(2,1)+CM(2,2));
%P_classifyAsSPAM = sum(Gauss_out ==ones(length(Labs_test),1))/length(Labs_test)
P_really_SPAM = recall*Prior_SPAM/P_classifyAsSPAM












