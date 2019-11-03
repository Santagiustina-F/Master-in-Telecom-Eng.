% Lab6 Decision trees
% VV ML_T2018
clear all;
close all;
clc;
 
 
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
 
 
minleaf = 1:20;
v_Pe_train = zeros(1,length(minleaf));
v_Pe_val = zeros(1, length(minleaf));
best_minleaf = 0;
best_val = realmax;
for i = 1:length(minleaf)
    % Tree classifier design
    tree = fitctree(X_train,Labels_train,'MinLeafSize',minleaf(i),'Prune','off');
    %view(tree,'mode','graph');
    %view(tree)
     
 
    % Measure Train error
    outputs = predict(tree,X_train);
    Tree_Pe_train=sum(Labels_train ~= outputs)/length(Labels_train);
    %fprintf('\n------- TREE CLASSIFIER ------------------\n')   
    %fprintf(1,' error Tree train = %g   \n', Tree_Pe_train)  
    %CM_Train=confusionmat(Labels_train,outputs)
    % Measure Val error
    outputs = predict(tree,X_val);
    Tree_Pe_val=sum(Labels_val ~= outputs)/length(Labels_val);
    %fprintf('\n-------------------------\n')   
    %fprintf(1,' error Tree val = %g   \n', Tree_Pe_val)  
    %CM_Val=confusionmat(Labels_val,outputs)
    
    v_Pe_train(i) = Tree_Pe_train;
    v_Pe_val(i) = Tree_Pe_val;
    if Tree_Pe_val < best_val
       best_val = Tree_Pe_val;
       best_minleaf = i;
    end
end
figure
subplot(2,1,1)
plot(minleaf,v_Pe_train)
title('Training error for different values of MinLeafSize parameter')
xlabel('MinLeafSize parameter')
ylabel('Training error')
 
subplot(2,1,2)
plot(minleaf,v_Pe_val)
title('Validation error for different values of MinLeafSize parameter')
xlabel('MinLeafSize parameter')
ylabel('Validation Error')
 
 
% Measure Test error
tree = fitctree(X_train,Labels_train,'MinLeafSize',best_minleaf,'Prune','off');
outputs = predict(tree,X_test);
Tree_Pe_test=sum(Labels_test ~= outputs)/length(Labels_test);
fprintf('\n-------------------------\n')   
fprintf(1,' error Tree test = %g   \n', Tree_Pe_test)
CM_Test=confusionmat(Labels_test,outputs)
view(tree,'mode','graph');
 
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Pre-prune / prune
 
% min_leaf = 1:20;
% alpha = 0:0.0001:0.1;
    
% TO DO, FOR MIN LEAVES AND TOP-DOWN CRITERIA
 
% for ParameterValues = 
%   Train a tree with the train BD and the train targets
%   Measure Train, Val and Test classification errors
%   Keep or save the tree classifier associated to the minimum val
%   error
% end for
% Plot train, val and test errors for each value of the parameter
 
% END TO DO
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Train an ensemble
