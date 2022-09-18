function W = varianceMatrix(a, var)
% This function generates the variance matrix W
% It has two inputs, a & v
% a = the amount of measured variables
% v = variance associated with each measured variable
W = eye(a);
for i = 1:a
    for j = 1:a
        if W(i,j) ~= 0
            W(i,j) = inv(var.^2);
        end    
    end
end
