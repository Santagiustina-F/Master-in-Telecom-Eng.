% lab2_gengauss_al
% Generation of data for three aligned gaussian distributions
% Small variance in the direction of alignment
%% Parameters
n_clases=3;
n_muestras=[500;500;500];       % Number of samples per class
n_feat=3;
dist=1;                         % Inter-Symbol Distance
M_Means=dist*[1,0,0;0,0,0;-1,0,0]; 	%Vector of means
% % Energy computation
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
Vsig2=[0.1 10 10];
Vsig2=3*Vsig2/norm(Vsig2);
Vsig2=sig*Vsig2; % % Eigenvalues associated with the principal directions
H=randn(n_feat);                      % Generation of eigenvectors associated with the principal directions for each class
[U, ~]=eig(H*H');                    
M_Means=M_Means*U;
for i_clase=1:n_clases
    M_cov(:,:,i_clase)=U'*diag(Vsig2)*U;%Matriz de covarianzas clase i_clase
end
clear H U i_clase Vsig2 sig

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
