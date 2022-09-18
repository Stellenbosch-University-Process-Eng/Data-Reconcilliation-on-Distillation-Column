%% Non-Linear Data Reconciliation
% This function blah blah 

%% Initialise
clear
clc

%% Load data
load('true_data', 'MM', 'X', 'tSol', 'true_data', 'v', 'p', 'u')

%% Measurements with Variance
% The function measureReal artificially corrupts the true data
a = 100;
variance = linspace(0.05,5,a); 
upperBound = [Inf(7,1); ones(6,1)];
lowerBound = zeros(13,1);

% Pre-allocation
Xhat     = zeros(13,1001);
XB = zeros(a,1001); LB = zeros(a,1001);
mapeM    = zeros(a,2); mape_avm = zeros(a,2);

% Variance analysis analysis
for i = 1:a
    [measured_data, time] = measureReal(MM, X, v, u, p, tSol, variance(i));

    % Set Up Matrices
    X0 = zeros(13,1);
    Y = [measured_data.L1; measured_data.LB; measured_data.LD; measured_data.LR;...
         measured_data.V0; measured_data.V4; measured_data.LF; measured_data.X1;...
         measured_data.XB; measured_data.XD; measured_data.Y0; measured_data.Y4;...
         measured_data.XF];
    W = varianceMatrix(13, variance(i));

    for j = 1:length(time)
        % Weighted objective function given current measurements Y(:,i)

        J = @(x) (Y(:,j) - x)'*W*(Y(:,j) - x);

        % Non-linear constraints f(x) = 0. See the bottom of the script
        % Find the non-linear estimates. Use the measurements as initial guess
        % See the help file for fmincon to understand the different required input arguments.
        Xhat(:,j) = fmincon(J, X0,[],[],[],[],lowerBound, upperBound, @nonLinearConstraints);
        X0        = Y(:,j);
    end

    XB(i,:) = Xhat(9,:);
    LB(i,:) = Xhat(2,:);

    % Error Metrics
    % Mean Absolute Percentage Error
    mapeM(i,1)    = mean(100*abs((true_data.XB(:,100:end) - measured_data.XB(:,100:end))./true_data.XB(:,100:end)));
    mape_avm(i,1) = mean(100*abs((true_data.XB(:,100:end) - XB(i,100:end))./true_data.XB(:,100:end)));
    mapeM(i,2)    = mean(100*abs((true_data.LB(:,100:end) - measured_data.LB(:,100:end))./true_data.LB(:,100:end)));
    mape_avm(i,2) = mean(100*abs((true_data.LB(:,100:end) - LB(i,100:end))./true_data.LB(:,100:end)));
end

%% Plot results
subplot(2,1,1)
patch([variance fliplr(variance)], [mapeM(:,1)' fliplr(mape_avm(:,1)')], 'y')
hold on
plot(variance, mapeM(:,1)', 'r', variance, mape_avm(:,1)', 'b')
hold off
xlabel("Variance"); ylabel("mapeValue - XB")
legend("Difference","Measurements","Data Reconciliation")
title("Comparison of MAPE values between measurements and DR -- XB")

subplot(2,1,2)
patch([variance fliplr(variance)], [mapeM(:,2)' fliplr(mape_avm(:,2)')], 'y')
hold on
plot(variance, mapeM(:,2)', 'r', variance, mape_avm(:,2)', 'b')
hold off
xlabel("Variance"); ylabel("mapeValue")
legend("Difference","Measurements","Data Reconciliation")
title("Comparison of MAPE values between measurements and DR -- LB")
sgtitle("Plots illustrating the effect of DR with increasing variance")

%% Save Data
save('nonlinearDR_data', 'mape_avm')



%% Function
function [g, f] = nonLinearConstraints(x)
g = []; % No inequality constraints
f = [x(7) - x(3) - x(2);...
     x(1) - x(2) - x(5);...
     x(6) - x(3) - x(4);...
     x(7)*x(13) - x(3)*x(10) - x(2)*x(9);...
     x(1)*x(8)  - x(2)*x(9)  - x(5)*x(11);...
     x(6)*x(12) - x(3)*x(10) - x(4)*x(10)];
end
