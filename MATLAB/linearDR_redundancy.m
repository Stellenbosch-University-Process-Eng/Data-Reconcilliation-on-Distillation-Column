%% Linear Data Reconciliation - Redundancy Analysis
% This main function loads the true data generated by simulating the model of
% the binary distillation column. It then artificially corrupts the true
% data (using measureReal) and performs linear data reconciliation on the corrupted
% 'measurements', for both AVM & SVM. Lastly, it evaluates the
% effectiveness of linear DR and the effect of reducing the amount of
% measurements. 

% Key:
% AVM - All Variables Measured 
% SVM - Some Variables Measured
% MAPE - Mean Absolute Percentage Error

%% Initialise
clear
clc

%% Load data
load('true_data', 'MM', 'X', 'tSol', 'true_data', 'v', 'p', 'u')

%% Measurements with Variance
% The function measureReal artificially corrupts the true data, with a
% specified variance
variance = 0.05;
[measured_data, time] = measureReal(MM, X, v, u, p, tSol, variance);

%% Setting up Matrices
% Measurement matrix - Matrix with all variables measured
measurements = [measured_data.L1; measured_data.LB; measured_data.LD; measured_data.LR;...
                measured_data.V0; measured_data.V1; measured_data.LF];
                   
% Variance Matrix - This function assigns a variance to each measurement.
% In reality, each measurement will have a different a variance, and some
% measurements could potentially have covariance. However, for
% simplification, all measurements are set to have the same variance with
% no covariance between the measurements
W = eye(7)*variance^2; 

% The A matrix
% The System of Equations
% 1. LF - LD - LB           = 0
% 2. L1 - LB - V0           = 0
% 3. V4 - LR - LD           = 0

%    L1 LB LD LR V0 V4 LF
A = [+0 -1 -1 +0 +0 +0 +1;...
     +1 -1 +0 +0 -1 +0 +0;...
     +0 +0 -1 -1 +0 +1 +0];
 
%% Linear DR - AVM 
xhat = measurements - (W\A')*((A*(W\A'))\(A*measurements));  % Data reconciliation performed for all measurements
LB_avm = xhat(2,:);                                          % Only evaluating the reconciled data of variable LB

%% Linear DR - SVM
% The generateLB function generates the reconciled estimates of LB for a
% specified number of unmeasured variable, v.
a = 2; % Maximum amount of unmeasured variables
LB_svm = zeros(a,1001); % Preallocation for faster runtime. This is done for many cases
for i = 1:a
   LB_svm(i,:) = generateLB(i, measured_data, variance);     % Reconciled value for variable LB, with specified amount of unmeasured variables
end

%% Error metrics
% MAPE - Mean Absolute Percentage Error
% This is the main metric which is used for evaluating the effectivness of
% DR. The MAPE value is calculated by subtracting the variable of interest
% with the true value, and dividing it by the true value. Thereafter, the
% mean is taken and multiplied by 100.
mapeM    = mean(100*abs((true_data.LB(:,100:end) - measured_data.LB(:,100:end))./true_data.LB(:,100:end))); % MAPE for the measurements
mape_avm = mean(100*abs((true_data.LB(:,100:end) - LB_avm(:,100:end))./true_data.LB(:,100:end)));           % MAPE for the reconciled data with AVM
mape_svm = zeros(2,1);
for i = 1:a
    mape_svm(i,1) = mean(100*abs((true_data.LB(:,100:end) - LB_svm(i,100:end))./true_data.LB(:,100:end)));  % MAPE for the reconciled data with SVM
end

% res - Residules
% The residules are used for the histogram plots & and the probability
% distribution plots
resM = true_data.LB - measured_data.LB;                             % Residuals for measurements
res_avm = true_data.LB - LB_avm;                                    % Residuals for reconciled data for AVM
res_svm = zeros(a,1001);
for i = 1:a
    res_svm(i,:) = true_data.LB - LB_svm(i,:);                      % Residual for reconciled data for SVM
end

% Density functions
[fm, xim] = ksdensity(resM(:,100:end));                             % Probability distribution values for the measurements
[favm, xiavm] = ksdensity(res_avm(:,100:end));                      % Probability distribution values for the reconciled data for AVM
fsvm = zeros(a,100); xisvm = zeros(2,100);
for i = 1:a
    [fsvm(i,:), xisvm(i,:)] = ksdensity(res_svm(i,100:end));        % Probability distribution values for the reconciled data for SVM
end

%% Display results
% Choose type of display
% Line graph               >> disp = 1
% Histogram                >> disp = 2
% Probability distribution >> disp = 3
disp = 3;

% Plot results - Line Graph
if disp == 1
    subplot(a+1,1,1)
    plot(time(100:end,:), true_data.LB(:,100:end), 'co', time(100:end,:), measured_data.LB(:,100:end), 'y', time(100:end,:), LB_avm(:,100:end), 'k')
    title("All Variables Measured")
    xlabel('Time (s)'); ylabel('LB');
    legend('Model', "Measurement with MAPE = "+num2str(mapeM)+"%", "Data Reconciliation with MAPE = "+num2str(mape_avm)+"%", 'Location', 'best')

    for i = 1:a
        subplot(a+1,1,i+1)
        plot(time(100:end,:), true_data.LB(:,100:end), 'co', time(100:end,:), measured_data.LB(:,100:end), 'y', time(100:end,:), LB_svm(i,100:end), 'k')
        title("Some Variables Measured: No. Unmeasured = "+num2str(i))
        xlabel('Time (s)'); ylabel('LB');
        legend('Model', "Measurement with MAPE = "+num2str(mapeM)+"%", "Data Reconciliation with MAPE = "+num2str(mape_svm(i,1))+"%", 'Location', 'best')
    end
    sgtitle("Measurements vs the reconciled values")
    
% Plot results - Histogram
elseif disp == 2
    subplot(a+1,1,1)
    histogram(resM(:,100:end),50,'FaceAlpha',0.1)
    hold on
    histogram(res_avm(:,100:end),50,'FaceAlpha',1)
    hold off
    title("All Variables Measured")
    xlabel('Time (s)'); ylabel('LB');
    legend("Measurement with MAPE = "+num2str(mapeM)+"%", "Data Reconciliation with MAPE = "+num2str(mape_avm)+"%", 'Location', 'Best')
    for i = 1:a
        subplot(a+1,1,i+1)
        histogram(resM(:,100:end),50,'FaceAlpha',0.1)
        hold on
        histogram(res_svm(i,100:end),50,'FaceAlpha',1)
        hold off
        if i == 1
            title("Some Variables Measured: No. Unmeasured = "+num2str(i) +" >> L1")
        elseif i == 2
            title("Some Variables Measured: No. Unmeasured = "+num2str(i) +" >> L1 & V4")
        end
        xlabel('Time (s)'); ylabel('LB');
        legend("Measurement with MAPE = "+num2str(mapeM)+"%", "Data Reconciliation with MAPE = "+num2str(mape_svm(i))+"%", 'Location', 'Best')
    end
    sgtitle("Histograms of the residuals for the measurements & the reconciled values")
end

% Plot results - Density Function
if disp == 3
    subplot(a+1,1,1)
    plot(xim, fm, 'y', xiavm, favm, 'b')
    title("All Variables Measured")
    xlabel('Time (s)'); ylabel('LB');
    legend("Measurement with MAPE = "+num2str(mapeM)+"%", "Data Reconciliation with MAPE = "+num2str(mape_avm)+"%", 'Location', 'Best')
    for i = 1:a
        subplot(a+1,1,i+1)
        plot(xim, fm, 'y', xisvm(i,:), fsvm(i,:), 'b')
        if i == 1
            title("Some Variables Measured: No. Unmeasured = "+num2str(i)+" >> L1")
        elseif i == 2
            title("Some Variables Measured: No. Unmeasured = "+num2str(i)+" >> L1 & V4")
        end        
        xlabel('Time (s)'); ylabel('LB');
        legend("Measurement with MAPE = "+num2str(mapeM)+"%", "Data Reconciliation with MAPE = "+num2str(mape_svm(i))+"%", 'Location', 'Best')
    end
    sgtitle("Probability distributions of the residuals for the measurements & the reconciled values")
end

% Display MAPE values in Table
NumberUnmeasuredVariables = ["M";"0";"1";"2"];
MAPE = [mapeM; mape_avm; mape_svm];
table(NumberUnmeasuredVariables, MAPE)

function LB = generateLB(v, measured_data, var)
% This function generates the reconciled estimates of the variable LB based
% on the number of unmeasured variables, v. This is achieved by firstly
% generating the necessary Ax & Au matrices. Thereafter, the required
% projection matrix is calculated, which is subsequently used to reconcile
% the LB variable.

% Below is key which specifies which variables were 'not measured'
% Key:
% v == 1 >> L1
% v == 2 >> L1 V4

% See system of equations above and the original A matrix

    L1 = [+0; +1; +0];
    LB = [-1; -1; +0];
    LD = [-1; +0; -1];
    LR = [+0; +0; -1];
    V0 = [+0; -1; +0];
    V4 = [+0; +0; +1];
    LF = [+1; +0; +0];

    if v == 1
        % Generate Matrix
        Ax = [LB LD LR V0 V4 LF];
        Au = L1;
        
        % Compute Projection Matrix
        [Q, ~] = qr(Au);
        s = 1;
        Q2 = Q(:, s+1:end);
        P = Q2';
        
        % Redefine measurement & variance matrix
        m = [measured_data.LB; measured_data.LD; measured_data.LR;...      % Measurement matrix has to correspond to the
             measured_data.V0; measured_data.V4; measured_data.LF];        % new Ax & Au matrices
        W = eye(6)*var^2;                                        % Variance matrix also has to change
        
        % Perform data reconcialiation
        xhat_1 = m - (W*(P*Ax)')*(((P*Ax)*W*(P*Ax)')\((P*Ax)*m));          % Reconciled values for each variable
        LB = xhat_1(1,:);                                                  % Reconciled value for variable interest
        
    elseif v == 2
        % Generate Matrix
        Ax = [LB LD LR V0 LF];
        Au = [L1 V4];

        % Compute Projection Matrix
        [Q, ~] = qr(Au);
        s = 2;
        Q2 = Q(:, s+1:end);
        P = Q2';
        
        % Redefine measurement matrix
        m = [measured_data.LB; measured_data.LD; measured_data.LR;...
             measured_data.V0; measured_data.LF];
        W = eye(5)*var^2;
        
        % Perform data reconcialiation
        xhat_2 = m - (W*(P*Ax)')*(((P*Ax)*W*(P*Ax)')\((P*Ax)*m));
        LB = xhat_2(1,:);
        
    end
end