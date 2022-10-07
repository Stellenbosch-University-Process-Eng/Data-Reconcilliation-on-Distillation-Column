%% Initialise
clear
clc

%% Load data
load('true_data', 'MM', 'X', 'tSol', 'true_data', 'v', 'p', 'u')

%% Measurements with Variance
% The function measureReal artificially corrupts the true data, with a
% specified variance
variance = 0.8;
[measured_data, time] = measureReal(MM, X, v, u, p, tSol, variance);

%% Hypothesis Testing - Chi Square Goodness of Fit test
% H0: Data contains no gross errors 
% H1: Data contains gross erros 
% A test statistic, calculated according to the textbook, will be compared with
% the test criterion, which is the chi squared value with a degrees of
% freedom equal the rank of A, evaluated at a selected confidence interval. If the
% test statistic is larger than x, H0 will be rejected.

% Define confidence interval
alpha = linspace(0.88,0.99,50);              % alpha >> Level of significance

% Define measurements
y = [measured_data.L1; measured_data.LB; measured_data.LD; measured_data.LR;...    % Data containing no gross erros
     measured_data.V0; measured_data.V1; measured_data.LF];
 
W = eye(7)*variance.^2; 

%    L1 LB LD LR V0 V4 LF     
A = [+0 -1 -1 +0 +0 +0 +1;...
     +0 +0 -1 -1 +0 +1 +0;...
     +1 -1 +0 +0 -1 +0 +0]; 

V = A*W*A';                                         % Covariance matrix of residuals
df = rank(A);                                       % Degrees of freedom equals rank of A 

%% Perform hypothesis testing while introducing gross errors into data
% A gross error will be introduced at every second time step, and will be
% introduced for a random variable
% j-loop >> Calculates the GED performance different confidence intervals
% i-loop >> Calculates the GED performance for specified confidence
% interval
for j = 1:length(alpha)
    for i = 1:1001
        if i < 500
            y(randi([1 7],1,1),i*2) = 0;         % Gross Error introduced for a random variable
        end

        r = A*y(:,i);                            % Residuals of all variables, at a specified time  
        test_stat      = (r')*(V\r);             % Test statistic - Calculated according Global Test method
        test_criterion = chi2inv(alpha(j),df);   % Test criterion - Evaluated at specified confidence interval

        if test_stat < test_criterion            % H0 is accepted
            if nnz(y(:,i)) < 7                   % Gross error is present
                Type2(i) = 1;                    % Incorrectly accepted H0
            else                                 % Gross error not present
                H0(i) = 1;                       % Correctly accepted H0
            end
        else                                     % H1 is accepted
            if nnz(y(:,i)) < 7                   % Gross error is present
                H1(i) = 1;                       % Correctly accepts H1
            else                                 % Gross error not present
                Type1(i) = 1;                    % Incorrectly accepted H1
            end
        end
    end

    % Results - GED Performance
    spec(j)        = sum(H0)/(sum(H0) + sum(Type1));
    sens(j)        = sum(H1)/(sum(H1) + sum(Type2));
    type1_error(j) = sum(Type1)/(sum(H0) + sum(Type1));
    type2_error(j) = sum(Type2)/(sum(H1) + sum(Type2));
    
    clear H0 H1 Type1 Type2
end

Performance_Parameter = ["Specificity"; "Sensitivity"; "Type 1 Error"; "Type 2 Error"];
Performance_Value     = [spec; sens; type1_error; type2_error];
table(Performance_Parameter, Performance_Value)

% Plot Results
subplot(2,2,1)
plot(alpha, spec)
xlim([0.88 0.99])
title("Specificity - True Negative")

subplot(2,2,2)
plot(alpha, sens)
xlim([0.88 0.99])
title("Sensitivity - True Positive")

subplot(2,2,3)
plot(alpha, type1_error)
xlim([0.88 0.99])
title("Type 1 Error - False Positive")

subplot(2,2,4)
plot(alpha, type2_error)
xlim([0.88 0.99])
title("Type 2 Error - False Negative")

sgtitle("Global Test GED Method Performance")
