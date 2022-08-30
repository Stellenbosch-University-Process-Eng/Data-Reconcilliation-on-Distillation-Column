%% Non-Linear Data Reconciliation
% This function blah blah 

%% Initialise
clear
clc

%% Load data
load('true_data', 'MM', 'X', 'tSol', 'true_data', 'v', 'p', 'u')

%% Measurements with Variance
% The function measureReal artificially corrupts the true data
variance = 0.05;   
[measured_data, time] = measureReal(MM, X, v, u, p, tSol, variance);
Xhat = zeros(25,1001);
XB   = zeros(4,1001);

%% Observability analysis
for i = 1:3
    % Set Up Matrices
    v = i-1; X0 = zeros(25,1);
    [Y, index] = measurements_Y(v, measured_data);
    W = varianceMatrix(length(index), variance);

    for j = 1:length(time)
        % Weighted objective function given current measurements Y(:,i)

        J = @(x) (Y(:,j) - x(index))'*W*(Y(:,j) - x(index));

        % Non-linear constraints f(x) = 0. See the bottom of the script
        % Find the non-linear estimates. Use the measurements as initial guess
        % See the help file for fmincon to understand the different required input arguments.
        Xhat(:,j) = fmincon(J, X0,[],[],[],[],zeros(25,1),[], @nonLinearConstraints);
        X0(index) = Y(:,j);
    end

    XB(i,:) = Xhat(18,:);

end

%% Error Metrics
% Mean Absolute Percentage Error
mapeM    = mean(100*abs((true_data.XB(:,100:end) - measured_data.XB(:,100:end))./true_data.XB(:,100:end)));
mape_avm = mean(100*abs((true_data.XB(:,100:end) - XB(1,100:end))./true_data.XB(:,100:end)));

% Residuals
resM    = true_data.XB(:,100:end) - measured_data.XB(1,100:end);
res_avm = true_data.XB(:,100:end) - XB(1,100:end);

% Probability distributuions
[fm, xim]     = ksdensity(resM);
[favm, xiavm] = ksdensity(res_avm);

% Preallocate
mape_svm = zeros(3,1);
res_svm = zeros(3,902);
fsvm = zeros(1,100); xisvm = zeros(1,100);
for i = 1:3
    mape_svm(i) = mean(100*abs((true_data.XB(:,100:end) - XB(i+1,100:end))./true_data.XB(:,100:end)));
    res_svm (i,:) = true_data.XB(:,100:end) - XB(i+1,100:end);
    [fsvm(i,:), xisvm(i,:)] = ksdensity(res_svm(i,:));
end

%% Plot results
subplot(4,1,1)
plot(xim, fm, 'y', xiavm, favm, 'k')
title("Probability distribution - All Variables Measured")
xlabel("Residual Value"); ylabel("Probability")
legend("Measurement with MAPE = "+num2str(mapeM)+"%","Non-linear DR with MAPE = "+num2str(mape_avm)+"%")

for i = 1:3
    subplot(4,1,i+1)
    plot(xim, fm, 'y', xisvm(i,:), fsvm(i,:), 'k')
    title("Probability distribution - No. = "+num2str(i))
    xlabel("Residual Value"); ylabel("Probability")
    legend("Measurement with MAPE = "+num2str(mapeM)+"%","Non-linear DR with MAPE = "+num2str(mape_svm(i))+"%")
end


%% Function
function [g, f] = nonLinearConstraints(x)
g = []; % No inequality constraints
f = [x(1) - x(5) - x(9);...
     x(2) - x(1) + x(9) - x(10);...
     x(3) + x(8) - x(2) + x(10) - x(11);...
     x(4) - x(3) + x(11) - x(12);...
     x(7) - x(4) + x(12) - x(13);...
     x(13) - x(6) - x(7);...
     x(1)*x(14) - x(5)*x(18) - x(9)*x(21);...
     x(13)*(x(25) - x(19));...
     x(2)*x(15) - x(1)*x(14) - x(10)*x(22) + x(9)*x(21);...
     x(3)*x(16) + x(8)*x(20) - x(2)*x(15) - x(11)*x(23) + x(10)*x(22);...
     x(4)*x(17) - x(3)*x(16) - x(12)*x(24) + x(11)*x(23);...
     x(7)*x(19) - x(4)*x(17) - x(13)*x(25) + x(12)*x(24)];
end

%% Function
function [Y, index] = measurements_Y(v, measured_data)
    if v == 0 % All variables measured
        Y = [measured_data.L1; measured_data.L2; measured_data.L3; measured_data.L4; measured_data.LB;...
             measured_data.LD; measured_data.LR; measured_data.LF; measured_data.V0; measured_data.V1;...
             measured_data.V2; measured_data.V3; measured_data.V4; measured_data.X1; measured_data.X2;...
             measured_data.X3; measured_data.X4; measured_data.XB; measured_data.XD; measured_data.XF;...
             measured_data.Y0; measured_data.Y1; measured_data.Y2; measured_data.Y3; measured_data.Y4];
        index = [1:25]; 
         
    elseif v == 1 % Remove >> Y4
        Y = [measured_data.L1; measured_data.L2; measured_data.L3; measured_data.L4; measured_data.LB;...
             measured_data.LD; measured_data.LR; measured_data.LF; measured_data.V0; measured_data.V1;...
             measured_data.V2; measured_data.V3; measured_data.V4; measured_data.X2; measured_data.X1;...
             measured_data.X3; measured_data.X4; measured_data.XB; measured_data.XD; measured_data.XF;...
             measured_data.Y0; measured_data.Y1; measured_data.Y2; measured_data.Y3];  
        index = [1:24]; 
         
    elseif v == 2 % Remove >> L4, X1, X4
        Y = [measured_data.L1; measured_data.L2; measured_data.L3; measured_data.LB;...
             measured_data.LD; measured_data.LR; measured_data.LF; measured_data.V0; measured_data.V1;...
             measured_data.V2; measured_data.V3; measured_data.V4; measured_data.X2;...
             measured_data.X3; measured_data.XB; measured_data.XD; measured_data.XF;...
             measured_data.Y0; measured_data.Y1; measured_data.Y2; measured_data.Y3; measured_data.Y4];
        index = [1:3,5:13,15:16,18:25]; 
         
    elseif v == 3 % Remove >> L1, V3, X1, X4, Y0, Y4
        Y = [measured_data.L2; measured_data.L3; measured_data.L4; measured_data.LB;...
             measured_data.LD; measured_data.LR; measured_data.LF; measured_data.V0; measured_data.V1;...
             measured_data.V2; measured_data.V4; measured_data.X2;...
             measured_data.X3; measured_data.XB; measured_data.XD; measured_data.XF;...
             measured_data.Y1; measured_data.Y2; measured_data.Y3];
        index = [2:11,13,15:16,18:20,22:24]; 
         
    elseif v == 4 % Remove >> L1, V3, X1, X3, X4, Y0, Y4
        Y = [measured_data.L2; measured_data.L3; measured_data.L4; measured_data.LB;...
             measured_data.LD; measured_data.LR; measured_data.LF; measured_data.V0; measured_data.V1;...
             measured_data.V2; measured_data.V4; measured_data.X2;...
             measured_data.XB; measured_data.XD; measured_data.XF;...
             measured_data.Y1; measured_data.Y2; measured_data.Y3];
        index = [2:11,13,15,18:20,22:24]; 
        
    end
end



