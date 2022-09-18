%% Comparison of Linear DR and Non-linear DR
% Load data
load('nonlinearDR_data', 'mape_avm')
mape_nlinearDR   = mape_avm(:,2);
load('linearDR_data', 'mape_avm', 'mapeM')
mape_linearDR    = mape_avm;


load('true_data', 'MM', 'X', 'tSol', 'true_data', 'v', 'p', 'u')


plot(linspace(0.05,5,100), mape_nlinearDR, 'b', linspace(0.05,5,100), mape_linearDR, 'r')
legend("Non-linear", "Linear")
xlabel("Variance"); ylabel("MAPE values for different variances")
title("Comparison of Linear vs Non-linear Data reconciliation")
