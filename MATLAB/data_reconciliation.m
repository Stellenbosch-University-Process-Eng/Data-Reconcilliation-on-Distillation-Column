%% Initialise
clear
clc

%% Load data
load('true_data', 'MM', 'X', 'tSol', 'v', 'p', 'u')

%% Measurements
% Define measurements
for i = 1:p.N
    m.("L"+num2str(i)) = v.L(i,:)'; 
end
m.LB = v.LB';
m.LD = v.LD';
m.LR = v.LR';
m.LF = u.LF(tSol);

m.V0 = v.V0';
for i = 1:p.N
    m.("V"+num2str(i)) = v.V(i,:)'; 
end

% Define measurement fields
for i = 1:p.N
    meas.fields{i} = "L"+num2str(i);
end
meas.fields{end+1} = "LB";
meas.fields{end+1} = "LD";
meas.fields{end+1} = "LR";
meas.fields{end+1} = "LF";

meas.fields{end+1} = "V0";
for i = 1:p.N
    meas.fields{end+1} = "V"+num2str(i);
end

% Define measurement structure
for i = 1:p.N
    meas.("L"+num2str(i)) = struct('func', @(t,m,u,v) m.("L"+num2str(i)), 'var', 0.1, 'T', 1, 'D', 0);
end
meas.LB = struct('func', @(t,m,u,v) m.LB, 'var', 0.1, 'T', 1, 'D', 0);
meas.LD = struct('func', @(t,m,u,v) m.LD, 'var', 0.1, 'T', 1, 'D', 0);
meas.LR = struct('func', @(t,m,u,v) m.LR, 'var', 0.1, 'T', 1, 'D', 0);
meas.LF = struct('func', @(t,m,u,v) m.LF, 'var', 0.1, 'T', 1, 'D', 0);

meas.V0 = struct('func', @(t,m,u,v) m.V0, 'var', 0.1, 'T', 1, 'D', 0);
for i = 1:p.N
    meas.("V"+num2str(i)) = struct('func', @(t,m,u,v) m.("V"+num2str(i)), 'var', 0.1, 'T', 1, 'D', 0);
end

meas.LF = struct('func', @(t,m,u,v) m.LF, 'var', 0.1, 'T', 1, 'D', 0);

% Call measurement function
y = measurements(tSol, m, u, v, meas);
time = y.L1.Time;
for i = 1:p.N
    measured_data.("L"+num2str(i)) = y.("L"+num2str(i)).Data(:,1:end);
end
measured_data.LB = y.LB.Data(:,1:end);
measured_data.LD = y.LD.Data(:,1:end);
measured_data.LR = y.LR.Data(:,1:end);
measured_data.LF = y.LF.Data(:,1:end);

measured_data.V0 = y.V0.Data(:,1:end);
for i = 1:p.N
    measured_data.("V"+num2str(i)) = y.("V"+num2str(i)).Data(:,1:end);
end

%% Linear Data Renconciliation - All Variables Measured
% Measurement values
measurements = [measured_data.L1; measured_data.L2; measured_data.L3;...
                measured_data.L4; measured_data.LB; measured_data.LD;...
                measured_data.LR; measured_data.V0; measured_data.V1;...
                measured_data.V2; measured_data.V3; measured_data.V4;...
                measured_data.LF];

% Variance
W = eye(13);
for i = 1:13
    for j = 1:13
        if W(i,j) ~= 0
            W(i,j) = 0.1;
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
 
%x_D  = y_model - W*A'*inv(A*W*A')*A*y_model;
y_DR_linear = measurements - inv(W)*A'*inv(A*inv(W)*A')*(A*measurements);
LB_DR = y_DR_linear(5,:);
LR_DR = y_DR_linear(7,:);

subplot(2,1,1)
plot(tSol, v.LB, 'c', time, measured_data.LB, 'r', time, LB_DR, 'k')
xlabel('Time (s)'); ylabel('LB');
legend('Model', 'Measurement', 'Data Reconciliation')

subplot(2,1,2)
plot(tSol, v.LR, 'c', time, measured_data.LR, 'r', time, LR_DR, 'k')
xlabel('Time (s)'); ylabel('LR');
legend('Model', 'Measurement', 'Data Reconciliation')
