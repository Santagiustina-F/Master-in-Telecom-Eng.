clear
close all

disp(' ')
disp('Feature selection by MDA dimensionality reduction')


%% Options / Initalitation
V_coor=1:256;             % 256 to take all features set 1:256

N_feat=length(V_coor);
% class name: Labels:
% 1(aa);2(ao);3(dcl);4(iy);5(sh);
N_classes=5;
N_fft=256;						%256 (8KHz) 128 (4KHz), 64 (2KHz), 32(1khZ)
%% Database load
load BD_phoneme

%% MEAN IS REMOVED FROM DATABASE
X=X-ones(length(Labels),1)*mean(X);

%% Database partition
P_train=0.7;
Index_train=[];
Index_test=[];
for i_class=1:N_classes
    index=find(Labels==i_class);
    N_i_class=length(index);
    [I_train,I_test] = dividerand(N_i_class,P_train,1-P_train);
    Index_train=[Index_train;index(I_train)];
    Index_test=[Index_test;index(I_test)];
end
% Train Selection
X_train=X(Index_train,:);
Labels_train=Labels(Index_train);
% Test Selection and mixing
X_test=X(Index_test,:);
Labels_test=Labels(Index_test);
clear Index_train Index_test index i_class N_i_class I_train I_test

%% Feature selection loop
all_LC_Pe_train = [];
all_QC_Pe_train = [];
all_LC_Pe_test = [];
all_QC_Pe_test = [];
all_X_train = X_train;
all_X_test = X_test;
for d= 1: (N_classes-1)
%d
W_fc=mda_ml(all_X_train,Labels_train,N_classes);
W_fc=W_fc(:,1:d);
X_train=all_X_train*W_fc;
X_test=all_X_test*W_fc;


%% Create a default (linear) discriminant analysis classifier:
linclass = fitcdiscr(X_train,Labels_train,'prior','empirical');
Linear_out = predict(linclass,X_train);
Linear_Pe_train=sum(Labels_train ~= Linear_out)/length(Labels_train);
%fprintf(1,' error Linear train = %g   \n', Linear_Pe_train)
Linear_out = predict(linclass,X_test);
Linear_Pe_test=sum(Labels_test ~= Linear_out)/length(Labels_test);
%fprintf(1,' error Linear test = %g   \n', Linear_Pe_test)

%% Create a quadratic discriminant analysis classifier:
quaclass = fitcdiscr(X_train,Labels_train,'discrimType','quadratic','prior','empirical');
Quadratic_out= predict(quaclass,X_train);
Quadratic_Pe_train=sum(Labels_train ~= Quadratic_out)/length(Labels_train);
%fprintf(1,' error Quadratic train = %g   \n', Quadratic_Pe_train)
Quadratic_out= predict(quaclass,X_test);
Quadratic_Pe_test=sum(Labels_test ~= Quadratic_out)/length(Labels_test);
%fprintf(1,' error Quadratic test = %g   \n', Quadratic_Pe_test)


%% Store error probabilities for current d'
all_LC_Pe_train = [all_LC_Pe_train; Linear_Pe_train];
all_QC_Pe_train = [all_QC_Pe_train ; Quadratic_Pe_train];
all_LC_Pe_test = [all_LC_Pe_test; Linear_Pe_test];
all_QC_Pe_test = [all_QC_Pe_test ; Quadratic_Pe_test ];

end
%% Plotting error curves

figure();
hold on
plot(all_LC_Pe_train, 'b', 'marker','+');
plot(all_QC_Pe_train, 'r', 'marker', '+');
plot(all_LC_Pe_test, 'g', 'marker','+');
plot(all_QC_Pe_test, 'k', 'marker','+');
legend({'LC Pe train','QC Pe train','LC Pe test','QC Pe test'});
hold off
grid
zoom on
xlabel('Number of features used')
ylabel('Probability of error')
title('Classification error probabilities with MDA');

