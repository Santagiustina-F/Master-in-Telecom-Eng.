function [ L ] = LogLikelihood( t, psi, nu, N )
%LogLikelihood compute the logarithm of the likelihood of obtaining the measured counts given the initial 
%state defined by the coefficients and the measurements operators.
L=0;
for n=1:16
    L = L + ((N* psi(:,n)' * PhysDM(t) * psi(:,n) - nu(n))^2) /(2*N*psi(:,n)' * PhysDM(t) * psi(:,n));
end


end

