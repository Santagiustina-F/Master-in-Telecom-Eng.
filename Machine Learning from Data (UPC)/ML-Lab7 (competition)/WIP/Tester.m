clc;
clear all;
close all;

load('test_data_ILDS.mat');
load('train_data_labels_ILDS.mat');

load('true_lab.mat');  %right prediction, REMOVE LATER

i_tree = 0;
i_hi = 0;


n_feat = size(Xtrain,2);
n_classes = 2;

Data=[Xtrain, Lab_Xtrain];
%Partition the data 60-20-20
indexes = randperm(length(Lab_Xtrain));
num_train = round(length(Lab_Xtrain)*80/100);
num_val = round(length(Lab_Xtrain)*20/100);
xtrain = Xtrain(indexes(1:num_train),:);
xtest = Xtrain(indexes(num_train+1:end),:);
%xval = Xtrain(indexes(num_train+1:num_train+1+num_val),:);
lab_train = Lab_Xtrain(indexes(1:num_train));
%lab_val = Lab_Xtrain(indexes(num_train+1:num_train+1+num_val));
lab_test = Lab_Xtrain(indexes(num_train+1:end));

%% Train and predict
%[trainedClassifier, validationAccuracy] = trainClassifier(Data);
pred = trainedClassifier.predictFcn(xtest);
f1_final = F1_check(lab_test,pred)
fin_pred = trainedClassifier.predictFcn(Xtest);

%% CHECK ON RIGHT PREDICTIONS, REMOVE LATER
f1_true = F1_check(true_lab,fin_pred)
confusionmat(true_lab,fin_pred)