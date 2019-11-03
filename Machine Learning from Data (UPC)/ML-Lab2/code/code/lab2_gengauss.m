% lab2_gengauss
% Generation of data for three non-aligned gaussian distributions
% Different covariance matrices
%% Parameters
n_clases=3;
n_muestras=[500;500;500];       % Number of samples per class
n_feat=3;
dist=1;                         % Inter-Symbol Distance
M_Means=dist*[1,1,-1;-1,0,-1;-1,-1,0]; 	%vector of means
% Energy computation
Energia=0;
for i_clase=1:n_clases
   V=squeeze(M_Means(i_clase,:));
   Energia=Energia+V*V';
end
Energia=Energia/i_clase;
% sigma computation
SNR=10^(SNR/10);
sig=Energia/SNR;
sig=sig/n_feat;
clear Energia V dist
%Variable to store the covariance matrix
M_cov=zeros(n_feat,n_feat,n_clases);
D=sig*[1 1 1;0.1 0.3 0.6;2 0.01 0.99];  % Eigenvalues associated with the principal directions of each class

for i_clase=1:n_clases
   H=randn(n_feat);                      % Generation of eigenvectors associated with the principal directions for each class
   [U, ~]=eig(H*H');                    
   M_cov(:,:,i_clase)=U*diag(D(i_clase,:))*U'; % Covariance matrix for class i_clase
end
clear H U i_clase sig

%% Generation of a gaussian training dataset
X_train=[];
Labels_train=[];
for i_clase=1:n_clases
    X_train=[X_train;mvnrnd(M_Means(i_clase,:),M_cov(:,:,i_clase),n_muestras(i_clase))];
    Labels_train=[Labels_train; i_clase*ones(n_muestras(i_clase),1)];
end

%% Generation of a gaussian test dataset
X_test=[];
Labels_test=[];
for i_clase=1:n_clases
    X_test=[X_test;mvnrnd(M_Means(i_clase,:),M_cov(:,:,i_clase),round(0.25*n_muestras(i_clase)))];
    Labels_test=[Labels_test; i_clase*ones(round(0.25*n_muestras(i_clase)),1)];
end
clear i_clase
