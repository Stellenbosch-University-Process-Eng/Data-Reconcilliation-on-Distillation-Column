%% Initialise
clear
clc

%% Load data
load('true_data', 'MM', 'X', 'tSol', 'true_data', 'v', 'p', 'u')

%% Measurements with Variance
% The function measureReal artificially corrupts the true data, with a
% specified variance
variance = 0.5;
[measured_data, time] = measureReal(MM, X, v, u, p, tSol, variance);

%% Hypothesis Testing - Chi Square Goodness of Fit test
% H0: Data contains no gross errors 
% H1: Data contains gross erros 
% A test statistic, calculated according to the textbook, will be compared with
% the test criterion, which is the chi squared value with a degrees of
% freedom equal the rank of A, evaluated at a selected confidence interval. If the
% test statistic is larger than x, H0 will be rejected.

% Define confidence interval
alpha = 0.9999%linspace(0.88,0.99,10);              % alpha >> Level of significance

% Define measurements
y = [measured_data.L1; measured_data.LB; measured_data.LD; measured_data.LR;...    % Data containing no gross erros
     measured_data.V0; measured_data.V1; measured_data.LF; measured_data.X1;...
     measured_data.XB; measured_data.XD; measured_data.Y0; measured_data.Y4;...
     measured_data.XF];
 
W = varianceMatrix(13,variance); 

%    L1 LB LD LR V0 V4 LF X1 XB XD Y0 Y4 XF         >> Jacobian Matrix
J = [+0 -1 -1 +0 +0 +0 +1 +0 +0 +0 +0 +0 +0;...
     +0 +0 -1 -1 +0 +1 +0 +0 +0 +0 +0 +0 +0;...
     +1 -1 +0 +0 -1 +0 +0 +0 +0 +0 +0 +0 +0;...
     +0 -1 -1 +0 +0 +0 +1 +0 -1 -1 +0 +0 +1;...
     +0 +0 -1 -1 +0 +1 +0 +0 +0 -1 +0 +1 +0;...
     +1 -1 +0 +0 -1 +0 +0 +1 -1 +0 -1 +0 +0];

V = J*W*J';                                         % Covariance matrix of residuals
df = rank(J);                                       % Degrees of freedom equals rank of A 

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

        r = J*y(:,i);                            % Residuals of all variables, at a specified time  
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
    % Table
    spec(j)        = sum(H0)/1001;
%    sens(j)        = sum(H1)/1001;
    type1_error(j) = sum(Type1)/1001;
%    type2_error(j) = sum(Type2)/1001;

end

% Performance_Parameter = ["Specificity"; "Sensitivity"; "Type 1 Error"; "Type 2 Error"];
% Performance_Value     = [spec; sens; type1_error; type2_error];
% table(Performance_Parameter, Performance_Value)

% % Plot Results
% subplot(2,1,1)
% plot(alpha, type1_error)
% subplot(2,1,2)
% plot(alpha, type2_error)
