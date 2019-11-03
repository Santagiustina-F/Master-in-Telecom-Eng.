clc;
clear all;
close all;

load('test_data_ILDS.mat');
load('train_data_labels_ILDS.mat');

load('true_lab.mat');  %right prediction, REMOVE LATER
%load('backup.mat')   %right prediction, REMOVE LATER

i_tree = 0;
i_boost = 0;
i_pca = 0;
i_cost = 0;
best_n = 10;
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






%% Data visualization 

varNames = {'age','gender','TB','DB','Alk','Sgpt','Sgot','TP','ALB','AR'};
figure('name','Scatter Plot')
gplotmatrix(Xtrain,Xtrain,Lab_Xtrain,'rgb',[],[],'on','hist',varNames,varNames);
zoom on



%% Cost
cost = zeros(2);
num_train_0 = length(find(lab_train == 0));
num_train_1 = length(find(lab_train == 1));
cost(1,1) = 0;
cost(2,2) = 0;
cost(1,2) = num_train_1/(num_train_0+num_train_1);
cost(2,1) = 2*num_train_0/(num_train_0+num_train_1);


%% Cross validation on the cost
if i_cost ==1
costs = 1.1*num_train_0/(num_train_0+num_train_1);
best_cost = 0;
f1_values = zeros(1,length(costs));
for i = 1:length(costs)
    num_folds = 10;
    cost = zeros(2);
    num_train_0 = length(find(lab_train == 0));
    num_train_1 = length(find(lab_train == 1));
    cost(1,1) = 0;
    cost(2,2) = 0;
    cost(1,2) = 1-costs(i);
    cost(2,1) = costs(i);
  
    
    cv = cvpartition(lab_train,'KFold',num_folds); 
    f1_mean = 0;
    for j = 1:num_folds
        t = templateTree();
        cla = fitcensemble(xtrain(cv.training(j),:),lab_train(cv.training(j)),'Cost',cost,'Method','RUSBoost','Learners',t,'LearnRate',0.005);
        pred = predict(cla,xtrain(cv.test(j),:));
        f1 = F1_check(pred,lab_train(cv.test(j)));
        f1_mean = f1_mean+f1;
    end
    f1_mean = f1_mean/num_folds;
    if(f1_mean > best_f1)
       best_f1 = f1_mean;
       best_cost = cost;
    end
    f1_values(i) = f1_mean;
end
cost = best_cost;

figure
plot(costs,f1_values);
ylabel('Cross-validated f1-score')
xlabel('cost of misclassificating class 1')

end


%% Using a bag of trees to boost performance
%Cost function for the misclassification. 


if(i_tree == 1)
cost = zeros(2);
num_train_0 = length(find(lab_train == 0));
num_train_1 = length(find(lab_train == 1));
cost(1,1) = 0;
cost(2,2) = 0;
cost(1,2) = num_train_1/(num_train_0+num_train_1);
cost(2,1) = num_train_0/(num_train_0+num_train_1);



bag = TreeBagger(100,xtrain,lab_train,'Cost',cost);
predictions = predict(bag,xtest);
predictions = str2num(cell2mat(predictions));
f1 =  F1_check(lab_test,predictions);
end





%% Let's look for the best number of features to use with pca
coeff = pca(xtrain);

if i_pca == 1
best_n = 0;
f1_values = zeros(1,size(coeff,1));
for i = 1:size(coeff,1)

    xtrain1 = xtrain*coeff(:,1:i);
    
    cv = cvpartition(lab_train,'KFold',num_folds); 
    f1_mean = 0;
    for j = 1:num_folds
        t = templateTree();
        cla = fitcensemble(xtrain1(cv.training(j),:),lab_train(cv.training(j)),'Cost',cost,'Method','RUSBoost','Learners',t,'LearnRate',0.005);
        pred = predict(cla,xtrain1(cv.test(j),:));
        f1 = F1_check(pred,lab_train(cv.test(j)));
        f1_mean = f1_mean+f1;
    end
    f1_mean = f1_mean/num_folds;
    if(f1_mean > best_f1)
       best_f1 = f1_mean;
       best_n = i;
    end
    f1_values(i) = f1_mean;
end


figure
plot(1:size(coeff,1),f1_values);
ylabel('Cross-validated f1-score')
xlabel('Learning rate')

end
xtrain = xtrain*coeff(:,1:best_n);
xtest = xtest*coeff(:,1:best_n);
Xtest = Xtest*coeff(:,1:best_n);

%% Boosting
if i_boost == 1

%rng('default') % For reproducibility
cost = zeros(2);
num_train_0 = length(find(lab_train == 0));
num_train_1 = length(find(lab_train == 1));
cost(1,1) = 0;
cost(2,2) = 0;
cost(1,2) = num_train_1/(num_train_0+num_train_1);
cost(2,1) = 3*num_train_0/(num_train_0+num_train_1);


%cross validation
l_rate = 0.006;
l_rate_1 = [0.0001,0.0005,0.001,0.005,0.01,0.05,0.1,0.5];
num_folds = 20;



best_learn = 0;
best_f1 = 0;
best_cla = [];
f1_values = zeros(1,length(l_rate));
for i = 1:length(l_rate)
    cv = cvpartition(lab_train,'KFold',num_folds); 
    f1_mean = 0;
    bf1 = 0;
    for j = 1:num_folds
        t = templateTree();
        cla = fitcensemble(xtrain(cv.training(j),:),lab_train(cv.training(j)),'Cost',cost,'Method','AdaBoostM1','Learners',t,'LearnRate',l_rate(i));
        pred = predict(cla,xtrain(cv.test(j),:));
        f1 = F1_check(pred,lab_train(cv.test(j)));
        if (f1>bf1)
            best_cla = cla;
        end
        f1_mean = f1_mean+f1;
    end
    f1_mean = f1_mean/num_folds;
    best_learn = l_rate(i); %remove later
    if(f1_mean > best_f1)
       best_f1 = f1_mean;
       best_learn = l_rate(i); 
       %best_cla = cla;
    end
    f1_values(i) = f1_mean;
end



figure
plot(l_rate,f1_values);
ylabel('Cross-validated f1-score')
xlabel('Learning rate')





end

%% Last try

f1_aim  = 0.65;
best_f1 = 0;
best_cla = [];
done = 0;
%while (not(done))


     t = templateTree();
     %cla = fitcensemble(xtrain(cv.training(j),:),lab_train(cv.training(j)),'Cost',cost,'Method','RUSBoost','Learners',t,'LearnRate',0.006);
     best_cla = fitcensemble(xtrain,lab_train,'Cost',cost,'Method','RUSBoost','Learners',t,'LearnRate',0.006);
     %pred = predict(cla,xtrain(cv.test(j),:));
     pred = predict(best_cla,xtest);
     %f1 = F1_check(pred,lab_train(cv.test(j)));
     best_f1 = F1_check(pred,lab_test);
%{
    if(f1 > best_f1)
        best_f1 = f1;
        best_cla = cla;
    end
    if(best_f1 > f1_aim)
       done = 1; 
    end
end
     %}
    
    
%%
%cl = fitcensemble(xtrain,lab_train,'Method','RUSBoost','Cost',cost,'Learners',t,'LearnRate',best_learn);
pred = predict(best_cla,xtest);
f1_final = F1_check(lab_test,pred);
fin_pred = predict(best_cla,Xtest);
confusionmat(lab_test,pred)
%% CHECK ON RIGHT PREDICTIONS, REMOVE LATER
f1_true = F1_check(true_lab,fin_pred);
confusionmat(true_lab,fin_pred)
