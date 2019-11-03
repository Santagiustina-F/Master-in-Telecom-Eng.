clc;
clear all;
close all;

load('test_data_ILDS.mat');
load('train_data_labels_ILDS.mat');

load('true_lab.mat');  %right prediction, REMOVE LATER

i_tree = 0;
i_hi = 1;


n_feat = size(Xtrain,2);
n_classes = 2;
%% Data pre-processing :
for k= 1:1:n_feat 
    Xtrain(:,k)=(Xtrain(:,k)- mean(Xtrain(:,k)))/sqrt(var(Xtrain(:,k)));
    Xtest(:,k)=(Xtest(:,k)-mean(Xtest(:,k)))/sqrt(var(Xtest(:,k)));
end
clear k;

%% Partition the data 60-20-20
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
gplotmatrix(xtrain,xtrain,lab_train,'bgr',[],[],'on','hist',varNames,varNames);
zoom on

%%  HISTOGRAMS
if i_visual==1
    figure('name','HISTOGRAMS')
    index= Lab_Xtrain==0;
    for i_feat=1:n_feat
        subplot(n_feat,2,2*i_feat-1)
        histfit(Xtrain(index,i_feat))
        grid
        zoom on
        ylabel(['Feat ',num2str(i_feat)]);
        title('Class 0');
    end
    index= Lab_Xtrain==1;
    for i_feat=1:n_feat
        subplot(n_feat,2,2*i_feat)
        histfit(Xtrain(index,i_feat))
        grid
        zoom on
        ylabel(['Feat ',num2str(i_feat)]);
        title('Class 1')
    end
    clear index i_feat
end

%% t-SNE 3d
if i_visual==1 
    rng default % for fair comparison
    Y3 = tsne(Xtrain,'Algorithm','barneshut','NumPCAComponents',10,'NumDimensions',3);
    figure
    scatter3(Y3(Lab_Xtrain==0,1),Y3(Lab_Xtrain==0,2),Y3(Lab_Xtrain==0,3),'ro');
    hold on
    scatter3(Y3(Lab_Xtrain==1,1),Y3(Lab_Xtrain==1,2),Y3(Lab_Xtrain==1,3),'bo');
    view(-93,14)
end


%% t-SNE 2d
if i_visual==1 
    rng default % for fair comparison
    Y2 = tsne(Xtrain,'Algorithm','barneshut','NumPCAComponents',10,'NumDimensions',2);
    figure
    plot(Y2(Lab_Xtrain==0,1),Y2(Lab_Xtrain==0,2),'ro');
    hold on
    plot(Y2(Lab_Xtrain==1,1),Y2(Lab_Xtrain==1,2),'bo');
end


%% Dimensionality reduction

[W_fc,score,latent]=pca(xtrain);
latent
last = input('Select number of dimensions to keep: ');
W_fc=W_fc(:,1:last);

x_train=xtrain*W_fc;
x_test=xtest*W_fc;


%% Using a bag of trees to boost performance
%Cost function for the misclassification. 
if(i_tree == 0)
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
%% Boosting
%rng('default') % For reproducibility
cost = zeros(2);
num_train_0 = length(find(lab_train == 0));
num_train_1 = length(find(lab_train == 1));
cost(1,1) = 0;
cost(2,2) = 0;
cost(1,2) = num_train_1/(num_train_0+num_train_1);
cost(2,1) = num_train_0/(num_train_0+num_train_1);


%cross validation
l_rate = 0.001:0.0005:0.01;
l_rate_1 = [0.0001,0.0005,0.001,0.005,0.01,0.05,0.1,0.5];
num_folds = 10;


best_learn = 0;
best_f1 = 0;
best_cla = [];
f1_values = zeros(1,length(l_rate));
for i = 1:length(l_rate)
    cv = cvpartition(lab_train,'KFold',num_folds); 
    f1_mean = 0;
    for j = 1:num_folds
        t = templateTree();
        cla = fitcensemble(xtrain(cv.training(j),:),lab_train(cv.training(j)),'Cost',cost,'Method','RUSBoost','Learners',t,'LearnRate',l_rate(i));
        pred = predict(cla,xtrain(cv.test(j),:));
        f1 = F1_check(pred,lab_train(cv.test(j)));
        f1_mean = f1_mean+f1;
    end
    f1_mean = f1_mean/num_folds;
    if(f1_mean > best_f1)
       best_f1 = f1_mean;
       best_learn = l_rate(i);
       best_cla = cla;
    end
    f1_values(i) = f1_mean;
end

figure
plot(l_rate,f1_values);
ylabel('Cross-validated f1-score')
xlabel('Learning rate')

%%
cl = fitcensemble(xtrain,lab_train,'Method','RUSBoost','Cost',cost,'Learners',t,'LearnRate',best_learn);
pred = predict(cl,xtest);
f1_final = F1_check(lab_test,pred)
fin_pred = predict(cl,Xtest);

%% CHECK ON RIGHT PREDICTIONS, REMOVE LATER
f1_true = F1_check(true_lab,fin_pred)
confusionmat(true_lab,fin_pred)

