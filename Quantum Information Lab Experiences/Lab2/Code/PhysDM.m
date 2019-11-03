function [ rho ] = PhysDM( t_p )
%PhysDM   Compute the tridiagonal matrix from its parameters (given as a row
%   vector of 16 real values) and the corresponding physical density matrix 

tridiagonal = [t_p(1)             0                  0                0    ; ...
               t_p(5)+i*t_p(6)   t_p(2)              0                0    ; ...
               t_p(11)+i*t_p(12) t_p(7)+i*t_p(8)   t_p(3)             0    ; ...
               t_p(15)+i*t_p(16) t_p(13)+i*t_p(14) t_p(9)+i*t_p(10) t_p(4) ; ];
           
rho = tridiagonal'*tridiagonal * (1.0 / trace(tridiagonal'*tridiagonal));
end

