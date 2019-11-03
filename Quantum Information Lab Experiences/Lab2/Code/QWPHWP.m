function [ psi ] = QWPHWP( h_1,q_1, h_2, q_2 )
%QWPHWP(h,q) function, used to compute the effect of QWP and HWP before
%projection onto |V>

V=[0;1];
H=[1;0];

psi =( QWPHWP_a(h_1,q_1)*QWPHWP_a(h_2,q_2)*kron(H,H) ...
     + QWPHWP_a(h_1,q_1)*QWPHWP_b(h_2,q_2)*kron(H,V) ...
     + QWPHWP_b(h_1,q_1)*QWPHWP_a(h_2,q_2)*kron(V,H) ...
     + QWPHWP_b(h_1,q_1)*QWPHWP_b(h_2,q_2)*kron(V,V) );
 
end
