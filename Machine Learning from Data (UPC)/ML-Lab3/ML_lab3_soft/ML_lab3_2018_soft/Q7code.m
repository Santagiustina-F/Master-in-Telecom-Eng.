% MC 2017
close all;
clear;
clc;
N_classes=10;
N_feat = 256;
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
%% Perform MDA feature selection with d' = 9
N_feat = 9;
COEFF= mda_ml(X_train,Labels_train+1,N_classes);
        W=COEFF(:,1:N_feat);
        X_train=X_train*W;
        X_test=X_test*W;
%% Create a fit the parameter h of a parzen classifier:

res = [1, 10, 20, 100];  %different values of k we are going to test
n_kfold = 10; 
X_train_copy = X_train;
Labels_train_copy = Labels_train;
X_test_copy = X_test;
Labels_test_copy = Labels_test;
train_err = zeros(length(res),1);
val_err = zeros(length(res),1);
aux = 1; %counter needed for train_err and val_err
cp = cvpartition(size(X_train_copy,1),'Kfold',n_kfold); %%
for iter1 = res
    avg_train_err = 0;
    avg_val_err = 0;
    for iter2=1:n_kfold 
        %X_train and Labels_train now contain only the values decided by
        %cvpartition. X_test contains the validation ones
        X_train = X_train_copy(find(training(cp,iter2)),:);
        Labels_train = Labels_train_copy(find(training(cp,iter2)));
        X_test = X_train_copy(find(test(cp,iter2)),:);
        Labels_test = Labels_train_copy(find(test(cp,iter2)));
        
        parzen_out = predict_parzen(X_train,Labels_train,N_classes,iter1,X_train);
        parzen_Pe_train=sum(Labels_train ~= parzen_out)/length(Labels_train);
        parzen_out = predict_parzen(X_train,Labels_train,N_classes,iter1,X_test);
        parzen_Pe_test=sum(Labels_test ~= parzen_out)/length(Labels_test);
     
        avg_train_err = avg_train_err + parzen_Pe_train;
        avg_val_err = avg_val_err + parzen_Pe_test;
    end
    train_err(aux) = avg_train_err/n_kfold;
    val_err(aux) = avg_val_err/n_kfold;
    aux = aux + 1;
end
%find and test the best value of h
[min_err, best_h] = min(val_err);
best_h = res(best_h);

parzen_out = predict_parzen(X_train_copy,Labels_train_copy,N_classes,best_h,X_train_copy);
parzen_Pe_train=sum(Labels_train_copy ~= parzen_out)/length(Labels_train_copy);

parzen_out = predict_parzen(X_train_copy,Labels_train_copy,N_classes,best_h,X_test_copy);
parzen_Pe_test=sum(Labels_test_copy ~= parzen_out)/length(Labels_test_copy);

%plot
figure
grid on
plot(res,train_err)
hold on
plot(res,val_err,'r')
 
xlabel('K')
ylabel('Error rates')
legend('training','validation')