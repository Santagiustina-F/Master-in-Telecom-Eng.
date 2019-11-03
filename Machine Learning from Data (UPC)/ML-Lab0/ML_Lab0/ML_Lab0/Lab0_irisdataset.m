% ML_Lab0_irisdataset
% Exploratory data analysis
% VV Aug 2018

clear all
close all

% READ DATASET
load my_iris_dataset.mat ;
x  = irisInputs ;
y = irisTargets ; 
% number of classes and features
[N_feat,n1] = size(x);
[N_class,n2] = size(y);
% number of samples
N_data = n1;
% labels
Labels = (1*y(1,:)+2*y(2,:)+3*y(3,:))';
X = x';


% HISTOGRAMS
figure('name','Histograms')
for i_class=1:N_class    
    index=find(Labels==i_class);  %select class to analyze
    for i_feat=1:N_feat
        subplot(N_class,N_feat,(i_class-1)*N_feat+i_feat)
        histfit(X(index,i_feat))
        grid
        zoom on
        title(['c' num2str(i_class) '  f' num2str(i_feat)])
    end
end

% KURTOSIS & SKEWNESS
figure('name','Kurtosis, Skewness');
for i_class = 1:N_class
    index = find(Labels==i_class);
    subplot(2,3,i_class);
    bar(kurtosis(X(index,:))-3)
    ylabel('KURTOSIS')
    xlabel('feature number')
    title(['c' num2str(i_class)]);
    grid
    subplot(2,3,N_class+i_class)
    bar(skewness(X(index,:)))
    ylabel('SKEWNESS');
    xlabel('feature number');
    title(['c' num2str(i_class)]);
    grid
end


%% CDF
figure('name','cdfplot')
for i_class = 1:N_class  
    index=find(Labels==i_class);
    for i_feat=1:N_feat
        subplot(N_class,N_feat,(i_class-1)*N_feat+i_feat)
        Aux=X(index,i_feat);
        Yaux=linspace(min(Aux),max(Aux),500);
        plot(Yaux,cdf('Normal',Yaux,mean(Aux),std(Aux)),'r');
        hold on
        cdfplot(X(index,i_feat))
        title(['c' num2str(i_class) '  f' num2str(i_feat)])
        zoom on
    end
end
clear Aux Yaux

%%  PLOTNORM
figure('name','Plotnorm')
for i_class = 1:N_class  
    index=find(Labels==i_class);
    for i_feat=1:N_feat
        subplot(N_class,N_feat,(i_class-1)*N_feat+i_feat)
        qqplot(X(index,i_feat))
        grid
        title(['c' num2str(i_class) '  f' num2str(i_feat)])
        zoom on
    end
end

%% BOXPLOTS    
figure('name','Boxplots per feature')
for i_feat=1:N_feat
    subplot(2,2,i_feat)
    boxplot(X(:,i_feat),Labels);
    xlabel('class')
    title(['f' num2str(i_feat)]);
end


%% SCATTER PLOT
varNames={'f1','f2','f3','f4'}
figure('name','Scatter Plot')
gplotmatrix(X,X,Labels,'bgr',[],[],'on','hist',varNames,varNames);
zoom on



%% THIS SHOULD BE DONE BY STUDENTS (REMOVE)

%% Confidence Intervals
% choose one feature
i_feat = 3
alphas=[0.05, 0.01, 0.001]
for j = 1:length(alphas)
    alfa=alphas(j)
    for i_class = 1:N_class  
        i_class
        index=find(Labels==i_class);
        df=length(index)-1
        M_mean=mean(X(index,i_feat))
        S_deviation=sqrt(var(X(index,i_feat)))   
        P=1-(alfa/2)
        t_alfa_2=tinv(P,df)
        Confidence_I=[M_mean-(t_alfa_2*S_deviation/sqrt(df+1));M_mean+(t_alfa_2*S_deviation/sqrt(df+1))]
    end
end


%% Goodness of fit
% choose one feature (H=1 only for feature 4 and classes 2 and 3, in all the other cases H=0
i_feat = 3;
 for i_class=1:N_class
     i_class
     index=find(Labels==i_class);
     V=X(index,i_feat);
     [H,P,STATS] = chi2gof(V,'ALPHA',0.001,'nbins' ,10)
 end






