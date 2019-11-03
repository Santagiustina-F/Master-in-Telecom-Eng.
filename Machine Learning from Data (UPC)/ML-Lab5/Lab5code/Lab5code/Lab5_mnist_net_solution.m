% VV - ML2018
% MNIST dataset

% Read data
trainset = csvread('mnist.csv', 1, 0);


% each row is a sample, 
% the first column is the label for the sample
% the remaining columns contain the pixels of a 28x28 grayscale image of a 
% handwritten digit, read by rows.



% Visualize some of the samples
figure;
colormap(gray)
for i=1:25;
    subplot(5,5,i);
    digit = reshape(trainset(i,2:end), [28,28])';
    imagesc(digit);                 % show image
    title(num2str(trainset(i,1)));  % show label
end

% original labels range from 0 to 9 but we will use '10' to represent '0'
% represent labels using one-hot encoding
% 1 --> [1; 0; 0; 0; 0; 0; 0; 0; 0; 0]
% 2 --> [0; 1; 0; 0; 0; 0; 0; 0; 0; 0]
% 3 --> [0; 0; 1; 0; 0; 0; 0; 0; 0; 0]
% ...
% 0 --> [0; 0; 0; 0; 0; 0; 0; 0; 0; 1]


n = size(trainset, 1);          % number of samples in the dataset
labels = trainset(:,1);         % 1st column is |label|
labels(labels == 0) = 10;       % use '10' to present '0'
labelsd = dummyvar(labels);     % convert label into a dummy variable
inputs = trainset(:,2:end);     % the rest of columns are predictors

inputs = inputs';               % transpose input
labels = labels';               % transpose label
labelsd = labelsd';             % transpose dummy variable

P_train=0.7;
P_val=0.15;
P_test=1-P_train-P_val;
Index_train = [];
Index_val = [];
Index_test = [];
N_classes = max(labels);
for i_class=1:N_classes
    index=find(labels==i_class);
    N_i_class=length(index);
    [I_train,I_val,I_test] = dividerand(N_i_class,P_train,P_val,P_test);
    Index_train=[Index_train, index(I_train)];
    Index_val=[Index_val, index(I_val)];
    Index_test=[Index_test, index(I_test)];
end
% Mixing of vectors not to have all belonging to a class together
Permutation=randperm(length(Index_train));
Index_train=Index_train(Permutation);
Permutation=randperm(length(Index_val));
Index_val=Index_val(Permutation);
Permutation=randperm(length(Index_test));
Index_test=Index_test(Permutation);
clear Permutation i_class index N_i_class I_train I_val I_test

X_train=inputs(:,Index_train);
Labelsd_train=labelsd(:,Index_train);
Labels_train=labels(Index_train);

X_val=inputs(:,Index_val);
Labelsd_val=labelsd(:,Index_val);
Labels_val=labels(Index_val);

X_test=inputs(:,Index_test);
Labelsd_test=labelsd(:,Index_test);
Labels_test=labels(Index_test);


% NEURAL NETWORK
Xdata = inputs;
Labels = labelsd;
numb_HL = [10, 50, 100, 150, 200, 250, 300]; %number of hidden layers to be validated
network_accuracy = zeros(1,length(numb_HL));
min_val_error = realmax;
best_numb_HL = numb_HL(1);

for i=1:length(numb_HL)
    % Create a Pattern Recognition Network
    hiddenLayerSize = numb_HL(i);
    net = patternnet(hiddenLayerSize);

    % Choose a Training Function
    net.trainFcn = 'trainscg';  % Scaled conjugate gradient 

    % Choose a Performance Function
    net.performFcn = 'crossentropy';  % Cross-Entropy


    net = configure(net,Xdata,Labels);

    % Setup Division of Data for Training, Validation, Testing
    % For a list of all data division functions type: help nndivide
    net.divideFcn = 'divideind';  % Divide data randomly
    net.divideMode = 'sample';  % Divide up every sample
    net.divideParam.trainInd = Index_train;
    net.divideParam.valInd = Index_val;
    net.divideParam.testInd = Index_test;

    % Train the Network
    net.trainParam.showWindow = true
    [net,tr] = train(net,Xdata,Labels);

    % Measure Train error
    outputs = net(X_train);
    [~, Index_out]=max(outputs);
    NN_Error_train=length(find(Labels_train~=Index_out))/length(Labels_train)
    NN_Acc_train = sum(Labels_train == Index_out)/length(Labels_train) 
    fprintf(1,' error NN train = %g   \n', NN_Error_train);
    CM_Train=confusionmat(Labels_train,Index_out)

    % Measure val error
    outputs = net(X_val);
    [~, Index_out]=max(outputs);
    NN_Error_val=length(find(Labels_val~=Index_out))/length(Labels_val)
    NN_Acc_val = sum(Labels_val == Index_out)/length(Labels_val) 
    fprintf(1,' error NN val = %g   \n', NN_Error_val);
    CM_Val=confusionmat(Labels_val,Index_out)
    
    if  NN_Error_val < min_val_error
         min_val_error = NN_Error_val;
         best_numb_HL = numb_HL(i);
    end
                
    % Measure Test error
    outputs = net(X_test);
    [~, Index_out]=max(outputs);
    NN_Error_test=length(find(Labels_test~=Index_out))/length(Labels_test);
    NN_Acc_test = sum(Labels_test == Index_out)/length(Labels_test) 
    fprintf(1,' error NN test = %g   \n', NN_Error_test);
    CM_Test=confusionmat(Labels_test,Index_out)
       
    network_accuracy(i) = NN_Acc_test;
end
    
%% Plot of accuracy w.r.t. the number of hidden layers

figure
plot(numb_HL,network_accuracy)
xlabel('Number of hidden layers');
ylabel('Accuracy on the test set');
title('Evolution of the neural network accuracy with the number of layers');

test_error_best_NN = 1-network_accuracy(best_numb_HL);
    




    

