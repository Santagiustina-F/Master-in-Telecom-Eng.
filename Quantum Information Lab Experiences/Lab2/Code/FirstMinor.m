function [ m ] = FirstMinor( matrix, i, j)
%FirstMinor Return the determinant of the matrix formed by deleting the i-th
%row and the j-th column.
matrix(i,:)= [];
matrix(:,j)= [];
m = det(matrix);
end

