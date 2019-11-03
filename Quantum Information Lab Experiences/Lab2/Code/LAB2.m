clear all;
close all;
clc;
%% Import the data
[~, ~, raw1] = xlsread('Tomo.xlsx','Tomography','H4:H19');
[~, ~, raw2] = xlsread('Tomo.xlsx','Tomography','J4:J19');
[~, ~, raw3] = xlsread('Tomo.xlsx','Tomography','D25:G40');

% Create output variable
n_phi_minus = cell2mat(raw1); %counts corresponding to the preparation of the state Phi-
n_phi_plus = cell2mat(raw2);%counts corresponding to the preparation of the state Phi+
angles = cell2mat(raw3); %each rows corrspond to  measurement and contain the used angles (minus the calibration offset) of HWPa, QWPa, HWPb, QWPb in degrees.

% Clear temporary variables
clearvars raw1 raw2 raw3;

%% Choose here between n_phi_minus and n_phi_plus counts
answer = {'0'};
while ( ~strcmp(answer{1},'+') && ~strcmp(answer{1},'-'))
    answer = inputdlg( 'Please choose if you want to use counts corresponding to the preparation of the state Phi- or Phi+, just write + or - in the imput prompt.' );
end
if (strcmp(answer{1},'+')) 
    counts = n_phi_plus;
    disp('You have chosen counts corresponding to Phi+.');
else
    counts = n_phi_minus ;
    disp('You have chosen counts corresponding to Phi-.');
end
%% Pauli matrices
Sigma0 = [1,0 ; 0,1];
Sigma1 = [0, -i ; i, 0];
Sigma2 = [0, 1 ; 1, 0];
Sigma3 = [1, 0 ; 0, -1];
%% Upsilon matrices allow to express the measurement operators Mu(i) as
% combinations of Pauli matrices
Upsilon = [1 0 0 0; 1/2 1/2 0 0; 1/2 0 1/2 0; 1/2 0 0 1/2];
Upsilon_Inv = [ 1 0 0 0 ; -1 2 0 0 ; -1 0 2 0 ; -1 0 0 2];
for i = 1:4
    Mu(:,:,i) = Upsilon(i,1)*Sigma0 + Upsilon(i,2)*Sigma1 + Upsilon(i,3)*Sigma2 + Upsilon(i,4)*Sigma3;
end
clear i
%% Gamma matrices of (3.9) allow to convert the 4*4 density matrix into a colum vector
%of length 16, we use the set of generators of the Lie algebra SU(2)*SU(2)
Gamma(:,:,1)= [0 1 0 0;1 0 0 0;0 0 0 1; 0 0 1 0];
Gamma(:,:,2)= [0 -i 0 0; i 0 0 0 ; 0 0 0 -i; 0 0 i 0];
Gamma(:,:,3)= [1 0 0 0 ; 0 -1 0 0 ; 0 0 1 0 ; 0 0 0 -1];
Gamma(:,:,4)= [0 0 1 0 ; 0 0 0 1; 1 0 0 0; 0 1 0 0];
Gamma(:,:,5)= [0 0 0 1; 0 0 1 0 ; 0 1 0 0 ; 1 0 0 0];
Gamma(:,:,6)= [0 0 0 -i; 0 0 i 0; 0 -i 0 0 ; i 0 0 0];
Gamma(:,:,7)= [0 0 1 0; 0 0 0 -1; 1 0 0 0; 0 -1 0 0];
Gamma(:,:,8)= [0 0 -i 0; 0 0 0 -i ; i 0 0 0 ; 0 i 0 0];
Gamma(:,:,9)= [0 0 0 -i ; 0 0 -i 0 ; 0 i 0 0 ; i 0 0 0];
Gamma(:,:,10)= [0 0 0 -1 ; 0 0 1 0 ; 0 1 0 0 ; -1 0 0 0];
Gamma(:,:,11)= [0 0 -i 0; 0 0 0 i ; i 0 0 0 ; 0 -i 0 0];
Gamma(:,:,12)= [1 0 0 0 ; 0 1 0 0 ; 0 0 -1 0 ; 0 0 0 -1];
Gamma(:,:,13)= [0 1 0 0; 1 0 0 0; 0 0 0 -1 ; 0 0 -1 0];
Gamma(:,:,14)= [0 -i 0 0 ; i 0 0 0 ; 0 0 0 i ; 0 0 -i 0];
Gamma(:,:,15)= [1 0 0 0 ; 0 -1 0 0 ; 0 0 -1 0 ; 0 0 0 1];
Gamma(:,:,16)= [1 0 0 0 ; 0 1 0 0 ; 0 0 1 0 ; 0 0 0 1];
Gamma = 1/2 * Gamma;

%% Check of Gamma matrices 
Delta = zeros(16,16);
for m=1:16
    for n=1:16
    Delta(m,n) = trace(Gamma(:,:,n) * Gamma(:,:,m) );
    end
end
if Delta == eye(16) disp('Gamma matrices should be ok !' )
else disp('Gamma matrices are not ok !' ) 
end
clear m n Delta; 

%% Tomographic analysis states
% (differ from the wanted ones only by a phase shift => equivalents )

%angles = [  45 0 45 0 ; 45 0 0 0 ; 0 0 0 0 ; 0 0 45 0 ; 22.5 0 45 0 ; 22.5 0 0 0 ; 22.5 45 0 0 ; 22.5 45 45 0  ; 22.5 45 22.5 0 ; ...
%            22.5 45 22.5 45 ; 22.5 0 22.5 45 ; 45 0 22.5 45 ; 0 0 22.5 45 ; 0 0 22.5 90 ; 45 0 22.5 90 ; 90 0 22.5 90];
%above angles are those used in the paper and are different in our LAB because the projection is made, after the
%QWP and HWP, on the horizontal axis and not the vertical one as in the
%paper (this leads to swapping a and b functions).
% Nonetheless, the projecting states are the same, so the hereafter computed psis are correct for both. 

d= size(angles);
psis = zeros(4,d(1));
for k =1:d(1)
    psis(:,k)=QWPHWP(angles(k,1),angles(k,2),angles(k,3),angles(k,4));
end
clear k;

%% B matrices of (3.11)
B = zeros(16,16);
for nu=1:16
    for mu=1:16
    B(nu,mu) = psis(:,nu)' * Gamma(:,:,mu) * psis(:,nu);
    end
end
clear nu mu ; 
B_inv = inv(B)
%% M matrices of (3.15)
%sum=zeros(4,4);
for mu=1:16
    M(:,:,mu) = zeros(4,4);
    for nu=1:16
    M(:,:,mu) = M(:,:,mu) + B_inv(nu,mu) * Gamma(:,:,nu);
    end
    %sum = sum + M(:,:,mu);
end
%sum
clear mu nu sum;
%% Closed form solution => possibly non-physical density matrix 
%counts= [34749 324 35805 444 16324 17521 13441 16901 17932 32028 15132 17238 13171 17170 16722 33586] % values in the paper.
N = sum(counts(1:4)); % constant dependent on the detector efficiency and light intensity

rho_err = zeros(4,4);
for mu=1:16
   rho_err = rho_err + M(:,:,mu) * counts(mu);
end
disp('Density matrix obtained from closed form solution tomography :');
rho_err = rho_err / N 
clear mu ; 
disp('Corresponding eigenvalues :');
eig(rho_err)
if (all(eig(rho_err) >= 0))
    disp('This density matrix correspond to a physical state.')
else
    disp('This density matrix is not non-negative definite and thus do not correspond to a physical state.')
    disp('We must us a maximum likelihood estimation.')
end

%% Definition of the physical density matrix through maximum-likelyhood


disp('Optimization is running...')

tridiag = Ts_from_DM(rho_err); %variable parameters of the tridiagonal matrix inferred from the previous step
fun = @(t)LogLikelihood(t,psis,counts, N) % Create an anonymous function of t alone that includes the workspace value of the parameter.
%options = optimset('PlotFcns',@optimplotfval); %set the options to use the plot function
t_physical=fminsearch(fun,fminsearch(fun,tridiag));
disp('Density matrix obtained from maximum likelihood tomography :');
rho_physical = PhysDM(t_physical)
disp('Corresponding eigenvectors and eigenvalues :');
[V,D]= eig(rho_physical) % eigenvalues are now all positives

close all;
%% Peres criterion
rho_physical_Tb = [rho_physical(1:2,1:2).' , rho_physical(1:2,3:4).' ; rho_physical(3:4,1:2).' , rho_physical(3:4,3:4).'] ; 
if (all(eig(rho_physical_Tb) >= 0)) 
    disp('By Peres criterion, this density matrix correspond to a separable state. ')
else 
    disp('By Peres criterion, this density matrix correspond to an entangled state.')
end
%% Von Neumann entropy 
S = -trace(logm(rho_physical)*rho_physical)*log2(exp(1)) %Von Neumann entropy in bits
%% Entanglement of formation
spin_flipped_rho = kron(Sigma1,Sigma1) * rho_physical' * kron(Sigma1,Sigma1);
lambda = sort(real(eig(rho_physical * spin_flipped_rho ))).^(1/2); %I take the square root of the eingenvalues and sort them
concurrence = max([0, lambda(4)-lambda(3)-lambda(2)-lambda(1)])% concurrence
p=real((1+sqrt(1-concurrence^2))/2);
ent_of_formation = -p*log2(p)-(1-p)*log2(1-p)
clear p,
%% Fidelity
phi_plus = 1/(sqrt(2))*[1 0 0 1].' ;
phi_minus = 1/(sqrt(2))*[1 0 0 -1].' ;
if (counts == n_phi_plus)
    des_state = phi_plus
end
if (counts == n_phi_minus)
    des_state = phi_minus
end
F = des_state.' * rho_physical * des_state %given that phi_plus and phi_minus are pure states
%% Entanglement of formation 
%% Ploting the initial non-physical state and the ML estimate one : 

width = 0.5;

figure(2);
bar3(real(rho_err),width,'b')
axis([0 5 0 5 -0.6 0.6] );
title('Real part of the tomographic density matrix.')
ylabel('Row number')
xlabel('Column number')

figure(3);
bar3(imag(rho_err),width,'b')
axis([0 5 0 5 -0.6 0.6] );
title('Immaginary part of the tomographic density matrix.')
ylabel('Row number')
xlabel('Column number')

figure(4);
bar3(real(rho_physical),width,'b')
axis([0 5 0 5 -0.6 0.6] );
title('Real part of the maximum-likelihood density matrix.')
ylabel('Row number')
xlabel('Column number')

figure(5);
bar3(imag(rho_physical),width,'b')
axis([0 5 0 5 -0.6 0.6] );
title('Immaginary part of the maximum-likelihood density matrix.')
ylabel('Row number')
xlabel('Column number')