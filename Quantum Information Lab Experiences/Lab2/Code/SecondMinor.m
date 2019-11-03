function [ m ] = SecondMinor( matrix, i, j, k, l)
%SecondMinor Return the determinant of the matrix formed by deleting the i-th
%row and the j-th column.
matrix(i,:)= [];
matrix(:,j)= [];
matrix(k,:)= [];
matrix(:,l)= [];
m = det(matrix);
end


