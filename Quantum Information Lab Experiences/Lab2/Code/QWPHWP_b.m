function [ b ] = QWPHWP_b( h, q )
%a(h,q) function, used to compute the effect of QWP and HWP before
%projection onto |H>

b = 1/sqrt(2)*(sind(2*h)-i*sind(2*(h-q)));

end