%% Linear Data Renconciliation - All Variables Measured
% Model values
y_model = [v.L; v.LB; v.LD; v.LR; v.V0; v.V; u.LF(tSol)'];

% Variance
% Need to automate this. Also need to figure out how to code this if
% covariances exists
W = eye(13);
for i = 1:13
    for j = 1:13
        if W(i,j) ~= 0
            W(i,j) = 1;
        end    
    end
end
W(5,5) = 1.1;
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
 
%x_D  = y_model - W*A'*inv(A*W*A')*A*y_model;
y_DR_linear = y_model - inv(W)*A'*inv(A*inv(W)*A')*(A*y_model);
LB_DR = y_DR_linear(5,:);
LR_DR = y_DR_linear(7,:);

subplot(2,1,1)
plot(tSol, v.LB, 'c', time, measured_data.LB, 'r', tSol, LB_DR, 'k')
xlabel('Time (s)'); ylabel('LB');
legend('Model', 'Measurement', 'Data Reconciliation')

subplot(2,1,2)
plot(tSol, v.LR, 'c', time, measured_data.LR, 'r', tSol, LR_DR, 'k')
xlabel('Time (s)'); ylabel('LR');
legend('Model', 'Measurement', 'Data Reconciliation')
