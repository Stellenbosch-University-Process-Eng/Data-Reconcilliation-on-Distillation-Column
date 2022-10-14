%% Comparison of Linear DR and Non-linear DR
% This code generates a plot of the MAPE values for the variable LB,
% generated from linear DR and non-linear DR. This is done for comparison
% between the two methods

%% Load data
load('nonlinearDR_data', 'mape_avm')
mape_nlinearDR   = mape_avm(:,2);              
load('linearDR_data', 'mape_avm', 'mapeM')
mape_linearDR    = mape_avm;

%% Plot results
plot(linspace(0.05,5,100), mape_nlinearDR, 'b', linspace(0.05,5,100), mape_linearDR, 'r')
legend("Non-linear", "Linear")
xlabel("Variance"); ylabel("LB - MAPE values for different variances")
title("Comparison of Linear vs Non-linear Data reconciliation")
