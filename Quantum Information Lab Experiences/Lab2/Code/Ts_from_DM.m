function [ t ] = Ts_from_DM( DM )
%Ts_from_DM Return the t values (parameters of the tridiagonal matrix)
%corresponding to the given density matrix. The real part is taken in case
%of complex values resulting from the negative-defineteness of the given
%density matrix.

t = zeros(16,1);
t(1) = real(sqrt(det(DM)/FirstMinor(DM,1,1)));
t(2) = real(sqrt( FirstMinor(DM,1,1)/SecondMinor(DM,1,1,2,2) )) ; 
t(3) = real(sqrt( SecondMinor(DM,1,1,2,2)/DM(4,4)  )); 
t(4) = real(sqrt( DM(4,4) )); 
t(5) = real( FirstMinor(DM,1,2) / sqrt(FirstMinor(DM,1,1)* SecondMinor(DM,1,1,2,2))); 
t(6) = imag( FirstMinor(DM,1,2) / sqrt(FirstMinor(DM,1,1)* SecondMinor(DM,1,1,2,2))) ;
t(7) = real( SecondMinor(DM,1,1,2,3) / sqrt(DM(4,4) * SecondMinor(DM,1,1,2,2) )) ; 
t(8) = imag( SecondMinor(DM,1,1,2,3) / sqrt(DM(4,4) * SecondMinor(DM,1,1,2,2) )) ; 
t(9) = real( DM(4,3) / sqrt(DM(4,4)) ); 
t(10)= imag( DM(4,3) / sqrt(DM(4,4)) );
t(11)= real( SecondMinor(DM,1,2,2,3)/ sqrt(DM(4,4) * SecondMinor(DM,1,1,2,2)) );
t(12)= imag( SecondMinor(DM,1,2,2,3)/ sqrt(DM(4,4) * SecondMinor(DM,1,1,2,2)) );
t(13)= real( DM(4,2) / sqrt(DM(4,4)) );
t(14)= imag( DM(4,2) / sqrt(DM(4,4)) );
t(15)= real( DM(4,1) / sqrt(DM(4,4)) );
t(16)= imag( DM(4,1) / sqrt(DM(4,4)) );
end

