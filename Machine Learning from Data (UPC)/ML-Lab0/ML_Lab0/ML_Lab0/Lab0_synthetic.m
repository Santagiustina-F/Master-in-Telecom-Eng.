% ML_Lab0_synthetic
% Synthetic distributions
% Options
clear
close all
i_histfit=1;                     %0 NO /1 YES: HISTOGRAMS
i_kurskew=1;				     %0 NO /1 YES: compute Kurtosis and Skewness
i_cdfplot=1;				     %0 NO /1 YES: compute cdf
i_qqplot=1;				         %0 NO /1 YES: compute QQ-plot

%% GENERATION of DISTRIBUTIONS
N=10000;
N_points=50; %histogram bins
rand('state',sum(100*clock))

% GAUSSIAN DISTRIBUTION
Y=5*randn(1,N)+3*ones(1,N);

% RAYLEIGH DISTRIBUTION
Y_abs=abs(5*randn(1,N)+5*1i*randn(1,N));

% UNIFORM DISTRIBUTION
rand('state',sum(100*clock))
Z=rand(1,N);

% LAPLACIAN DISTRIBUTION
i_1=find(Z<0.5);
i_2=find(Z>0.5);
Z_Lap(i_1)=sqrt(0.5)*log(2*Z(i_1));
Z_Lap(i_2)=-sqrt(0.5)*log(2*(1-Z(i_2)));

Z=Z-0.5; %remove mean for uniform distribution

% DATA MATRIX
XX=[Y;Y_abs;Z_Lap;Z];

%% HISTOGRAMS
if i_histfit==1
    figure('name','Histograms')
    subplot(2,2,1)
    histfit(Y,N_points)
    title('Normal Distribution')
    grid
    subplot(2,2,2)
    histfit(Y_abs,N_points)
    title('Rayleigh Distribution')
    grid
    subplot(2,2,3)
    histfit(Z_Lap,N_points)
    title('Laplacian Distribution')
    grid
    subplot(2,2,4)
    histfit(Z,N_points)
    title('Uniform Distribution')
    grid
end


%% cdfplot
if i_cdfplot==1
    figure('name','cdfplot')
    subplot(2,2,1)
    Yaux=linspace(min(Y),max(Y),500);
    plot(Yaux,cdf('Normal',Yaux,mean(Y),std(Y)),'r');
    hold on
    cdfplot(Y)
    title('Normal Distribution')
    
    subplot(2,2,2)
    Yaux=linspace(min(Y_abs),max(Y_abs),500);
    plot(Yaux,cdf('Normal',Yaux,mean(Y_abs),std(Y_abs)),'r');
    hold on
    cdfplot(Y_abs)
    title('Rayleigh Distribution')
    
    subplot(2,2,3)
    Yaux=linspace(min(Z_Lap),max(Z_Lap),500);
    plot(Yaux,cdf('Normal',Yaux,mean(Z_Lap),std(Z_Lap)),'r');
    hold on
    cdfplot(Z_Lap)
    title('Laplacian Distribution')
    
    subplot(2,2,4)
    Yaux=linspace(min(Z),max(Z),500);
    plot(Yaux,cdf('Normal',Yaux,mean(Z),std(Z)),'r');
    hold on
    cdfplot(Z)
    title('Uniform Distribution')
    
    clear Yaux
end


%% KURTOSIS-SKEWNESS
if i_kurskew==1
    figure('name','KURTOSIS-SKEWNESS')
    subplot(1,2,1)
    bar(kurtosis(XX')-3)
    grid
    title('KURTOSIS')
    subplot(1,2,2)
    bar(skewness(XX'))
    grid
    title('SKEWNESS')
end

%% PLOTNORM
if i_qqplot==1
    figure('name','qqplot=normplot')
    subplot(2,2,1)
    qqplot(Y)
    grid
    title('Normal Distribution')
    subplot(2,2,2)
    qqplot(Y_abs)
    grid
    title('Rayleigh Distribution')
    subplot(2,2,3)
    qqplot(Z_Lap)
    grid
    title('Laplacian Distribution')
    subplot(2,2,4)
    qqplot(Z)
    grid
    title('Uniform Distribution')
end