%% Non-Linear Data Reconciliation
% This function blah blah 

%% Initialise
clear
clc

%% Load data
load('true_data', 'MM', 'X', 'tSol', 'true_data', 'v', 'p', 'u')

%% Measurements with Variance
% The function measureReal artificially corrupts the true data
variance = 0.01;
[measured_data, time] = measureReal(MM, X, v, u, p, tSol, variance);

%% Set Up Matrices
W = varianceMatrix(25, variance);
Y = [measured_data.L1; measured_data.L2; measured_data.L3; measured_data.L4; measured_data.LB;...
     measured_data.LD; measured_data.LR; measured_data.LF; measured_data.V0; measured_data.V1;...
     measured_data.V2; measured_data.V3; measured_data.V4; measured_data.X1; measured_data.X2;...
     measured_data.X3; measured_data.X4; measured_data.XB; measured_data.XD; measured_data.XF;...
     measured_data.Y0; measured_data.Y1; measured_data.Y2; measured_data.Y3; measured_data.Y4];
 
for i = 1:length(time)
    % Weighted objective function given current measurements Y(:,i)
    J = @(x) (Y(:,i) - x)'*W*(Y(:,i) - x);
    
    % Non-linear constraints f(x) = 0. See the bottom of the script
    % Find the non-linear estimates. Use the measurements as initial guess
    % See the help file for fmincon to understand the different required input arguments.
    Xhat(:,i) = fmincon(J, Y(:,i),[],[],[],[],zeros(25,1),[], @nonLinearConstraints);
end

%% Redefining Measurement Matrix
% Thus, this will the code required

%% Error Metrics
XB_non = Xhat(18,:);
LB_non = Xhat(5,:);

mapeM    = mean(100*abs((true_data.XB(:,100:end) - measured_data.XB(:,100:end))./true_data.XB(:,100:end)));
mape_avm = mean(100*abs((true_data.XB(:,100:end) - XB_non(:,100:end))./true_data.XB(:,100:end)));

%% Plot results
subplot(2,1,1)
plot(time,true_data.XB,'bo',time,measured_data.XB,'y',time,XB_non,'k')
title("Molar fraction - Non-linear DR")
xlabel("Time"); ylabel("XB - Bottoms molar fraction")
legend('Model',"Measurement with MAPE = "+num2str(mapeM)+"%","Non-linear DR with MAPE = "+num2str(mape_avm)+"%")
subplot(2,1,2)
plot(time,true_data.LB,'bo',time,measured_data.LB,'y',time,LB_non,'k')
title("Liquid molar flowrate - Non-linear DR")
xlabel("Time"); ylabel("LB - Bottoms molar flowrate")
legend('Model','Measurement','Non-linear DR')


 

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



