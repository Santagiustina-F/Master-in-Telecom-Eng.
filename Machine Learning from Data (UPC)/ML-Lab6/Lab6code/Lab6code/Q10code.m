% Lab6 Decision trees
% VV ML_T2018

load data_ionosphere % Contains X and XLabels variables

N_classes = 2;
N_samp = length(XLabels);

% training, validation and test indices
rng(1); % for reproducibility
P_train=0.6;
P_val=0.2;
P_test=1-P_train-P_val;
Index_train=[];
Index_val=[];
Index_test=[];

for i_class=1:N_classes
    index=find(XLabels==i_class);
    N_i_class=length(index);
    [I_train,I_val,I_test] = dividerand(N_i_class,P_train,P_val,P_test);
    Index_train=[Index_train;index(I_train)];
    Index_val=[Index_val;index(I_val)];
    Index_test=[Index_test;index(I_test)];
end
% Mixing of vectors not to have all belonging to a class together
Permutation=randperm(length(Index_train));
Index_train=Index_train(Permutation);
Permutation=randperm(length(Index_val));
Index_val=Index_val(Permutation);
Permutation=randperm(length(Index_test));
Index_test=Index_test(Permutation);
clear Permutation i_class index N_i_class I_train I_val I_test

% generation of training, validation and test sets
X_train=X(Index_train,:);
Labels_train=XLabels(Index_train);
X_val=X(Index_val,:);
Labels_val=XLabels(Index_val);
X_test=X(Index_test,:);
Labels_test=XLabels(Index_test);

%%%%%%%%%%%%%%%%%%%%%%%%%

% Train an ensemble
ensemble = fitcensemble(X_train,Labels_train);



% Measure Train error
outputs = predict(ensemble,X_train);
ensemble_Pe_train=sum(Labels_train ~= outputs)/length(Labels_train);
fprintf('\n------- ensemble CLASSIFIER ------------------\n')   
fprintf(1,' error ensemble train = %g   \n', ensemble_Pe_train)  
CM_Train=confusionmat(Labels_train,outputs)
% Measure Val error
outputs = predict(ensemble,X_val);
ensemble_Pe_val=sum(Labels_val ~= outputs)/length(Labels_val);
fprintf('\n-------------------------\n')   
fprintf(1,' error ensemble val = %g   \n', ensemble_Pe_val)  
CM_Val=confusionmat(Labels_val,outputs)
% Measure Test error
outputs = predict(ensemble,X_test);
ensemble_Pe_test=sum(Labels_test ~= outputs)/length(Labels_test);
fprintf('\n-------------------------\n')   
fprintf(1,' error ensemble test = %g   \n', ensemble_Pe_test)
CM_Test=confusionmat(Labels_test,outputs)




