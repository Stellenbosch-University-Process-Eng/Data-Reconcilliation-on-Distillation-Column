%% Linear Data Renconciliation - All Variables Measured
% Model values
y_model = [v.L; v.LB; v.LD; v.LR; v.V0; v.V; u.LF(tSol')];

% Variance
% Need to automate this. Also need to figure out how to code this if
% covariances exists
V = [0.6724; 0.2809; 0.2116; 0.5041; 0.2025; 1.44; 0.5; 0.5; 0.5; 0.5; 0.5; 0.5; 1];
W = eye(13);
for i = 1:13
    for j = 1:13
        if W(i,j) ~= 0
            W(i,j) = V(i);
        end    
    end
end

% The System of Equations
% 1. L1 - LB - V0           = 0
% 2. LF + L2 - L1 + V0 - V1 = 0
% 3. L3 - L2 + V1 - V2      = 0
% 4. L4 - L3 + V2 - V3      = 0
% 5. LR - L4 + V3 - V4      = 0
% 6. V4 - LR - LD           = 0

% Also need automate this
%    L1 L2 L3 L4 LB LD LR V0 V1 V2 V3 V4 LF
A = [+1 +0 +0 +0 -1 +0 +0 -1 +0 +0 +0 +0 +0;... 
     -1 +1 +0 +0 +0 +0 +0 +1 -1 +0 +0 +0 +1;... 
     +0 -1 +1 +0 +0 +0 +0 +0 +1 -1 +0 +0 +0;... 
     +0 +0 -1 +1 +0 +0 +0 +0 +0 +1 -1 +0 +0;... 
     +0 +0 +0 -1 +0 +0 +1 +0 +0 +0 +1 -1 +0;... 
     +0 +0 +0 +0 +0 -1 -1 +0 +0 +0 +0 +1 +0];  
 
%x_D  = xDR - I*A'*inv(A*I*A')*A*xDR;
y_DR_linear = y_model - inv(W)*A'*inv(A*inv(W)*A')*(A*y_model);