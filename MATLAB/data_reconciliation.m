%% Initialise
clear
clc

%% Load data
load('true_data', 'MM', 'X', 'tSol', 'true_data', 'v', 'p', 'u')

%% Measurements with Variance
variance = 0.1;
[measured_data, time] = measureReal(v, u, p, tSol, variance);

%% Setting up Matrices
% Measurement values
% Liquid Measurements
measurements_L = zeros(p.N,length(time));
for i = 1:p.N
    measurements_L(i,:) = measured_data.("L"+num2str(i));
end
measurements_LB = measured_data.LB;
measurements_LD = measured_data.LD;
measurements_LR = measured_data.LR;
measurements_LF = measured_data.LF;

% Vapour Measurements
measurements_V0 = measured_data.V0;
measurements_V = zeros(p.N,length(time));
for i = 1:p.N
    measurements_V(i,:) = measured_data.("V"+num2str(i));
end

% Measurement & Model Matrix
measurements = [measurements_L; measurements_LB; measurements_LD;...
                measurements_LR; measurements_V0; measurements_V;...
                measurements_LF];
                   
% Variance Matrix
W = eye(13);
for i = 1:13
    for j = 1:13
        if W(i,j) ~= 0
            W(i,j) = variance;
        end    
    end
end

% The A matrix

% The System of Equations
% 1. L1 - LB - V0           = 0
% 2. L2 - L1 + V0 - V1      = 0
% 3. L3 + LF - L2 + V1 - V2 = 0
% 4. L4 - L3 + V2 - V3      = 0
% 5. LR - L4 + V3 - V4      = 0
% 6. V4 - LR - LD           = 0
% 7. LF - LD - LB           = 0

%    L1 L2 L3 L4 LB LD LR V0 V1 V2 V3 V4 LF
A = [+1 +0 +0 +0 -1 +0 +0 -1 +0 +0 +0 +0 +0;...
     -1 +1 +0 +0 +0 +0 +0 +1 -1 +0 +0 +0 +0;... 
     +0 -1 +1 +0 +0 +0 +0 +0 +1 -1 +0 +0 +1;... 
     +0 +0 -1 +1 +0 +0 +0 +0 +0 +1 -1 +0 +0;... 
     +0 +0 +0 -1 +0 +0 +1 +0 +0 +0 +1 -1 +0;... 
     +0 +0 +0 +0 +0 -1 -1 +0 +0 +0 +0 +1 +0];
 
%     LB LR LF 
Ax = [-1 +0 +0;...
      +0 +0 +0;...
      +0 +0 +1;...
      +0 +0 +0;...
      +0 +1 +0;...
      +0 -1 +0];

%     L1 L2 L3 L4 LD V0 V1 V2 V3 V4
Au = [+1 +0 +0 +0 +0 -1 +0 +0 +0 +0;...
      -1 +1 +0 +0 +0 +1 -1 +0 +0 +0;... 
      +0 -1 +1 +0 +0 +0 +1 -1 +0 +0;... 
      +0 +0 -1 +1 +0 +0 +0 +1 -1 +0;... 
      +0 +0 +0 -1 +0 +0 +0 +0 +1 -1;... 
      +0 +0 +0 +0 -1 +0 +0 +0 +0 +1];

y_DR_linear = measurements - W\A'*inv(A*(W\A'))*(A*measurements);
LB_DR = y_DR_linear(5,:);
LR_DR = y_DR_linear(7,:);

%% Error metrics
SE_M_LB  = (true_data.LB - measured_data.LB).^2;
SE_DR_LB = (true_data.LB - LB_DR).^2;

SE_M_LR  = (true_data.LR - measured_data.LR).^2;
SE_DR_LR = (true_data.LR - LR_DR).^2;

MSE_M_LB  = mean(SE_M_LB(:,100:end));
MSE_DR_LB = mean(SE_DR_LB(:,100:end));

MSE_M_LR  = mean(SE_M_LR(:,100:end));
MSE_DR_LR = mean(SE_DR_LR(:,100:end));

%% Plot results
subplot(2,2,1)
plot(time(100:end,:), true_data.LB(:,100:end), 'co', time(100:end,:), measured_data.LB(:,100:end), 'y', time(100:end,:), LB_DR(:,100:end), 'k')
xlabel('Time (s)'); ylabel('LB');
legend('Model', 'Measurement', 'Data Reconciliation', 'Location', 'Best')

subplot(2,2,2)
plot(time(100:end,:), true_data.LR(:,100:end), 'co', time(100:end,:), measured_data.LR(:,100:end), 'y', time(100:end,:), LR_DR(:,100:end), 'k')
xlabel('Time (s)'); ylabel('LR');
legend('Model', 'Measurement', 'Data Reconciliation', 'Location', 'Best')

subplot(2,2,3)
plot(time(100:end,:), SE_M_LB(:,100:end), 'y', time(100:end,:), SE_DR_LB(:,100:end), 'k')
xlabel('Time (s)'); ylabel('LB');
legend("Measurement with MSE of "+num2str(MSE_M_LB), "Data Reconciliation with MSE of "+num2str(MSE_DR_LB), "Location", "Best")

subplot(2,2,4)
plot(time(100:end,:), SE_M_LR(:,100:end), 'y', time(100:end,:), SE_DR_LR(:,100:end), 'k')
xlabel('Time (s)'); ylabel('LR');
legend("Measurement with MSE of "+num2str(MSE_M_LR), "Data Reconciliation with MSE of "+num2str(MSE_DR_LR), "Location", "Best")


