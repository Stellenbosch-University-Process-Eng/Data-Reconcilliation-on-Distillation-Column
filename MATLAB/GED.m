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
% freedom equal the rank of A, evaluated at a selected value of significance. If the
% test statistic is larger than x, H0 will be rejected.
alpha = 0.85;     %% alpha >> Level of significance

y = [measured_data.L1; measured_data.LB; measured_data.LD; measured_data.LR;...    % Data contained no gross erros
     measured_data.V0; measured_data.V1; measured_data.LF];
W = varianceMatrix(7, variance); 
A = [+0 -1 -1 +0 +0 +0 +1;...
     +1 -1 +0 +0 -1 +0 +0;...
     +0 +0 -1 -1 +0 +1 +0];
df = rank(A);                                                                      % Degrees of freedom equals rank of A 

%% Perform hypothesis testing while introducing gross errors into data
% A gross error will be introduced at every time step. Thus, type 1 errors
% are not evaluated, only type 2.
for i = 1:1001
    y(randi([1 7],1,1),i) = 0;       % Gross Error introduced for a random variable
    
    r = A*y(:,i);
    V = A*W*A';
    
    test_stat      = (r')*(V\r);          % Test statistic - Calculated according textbook
    test_criterion = chi2inv(alpha,df);    % Test criterion - Evaluated at specified level of significance 
    
    if test_stat < test_criterion         % For when test_stat lies left of test_criterion of Chi-square pdf 
        H0(i) = 0;                        % Accept H0 hypothesis - Type 2 error          
    else
        H0(i) = 1;                        % Reject H0 hypothesis - True
    end
end

%% Results - P
GED_performance = sum(H0)/1001