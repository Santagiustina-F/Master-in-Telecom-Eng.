function [ a ] = QWPHWP_a( h, q )
%a(h,q) function, used to compute the effect of QWP and HWP before
%projection onto |H>

a = 1/sqrt(2)*(cosd(2*h)+i*cosd(2*(h-q))); %modified sign
end