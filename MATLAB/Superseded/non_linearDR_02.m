%% Non-Linear Data Reconciliation
% This function blah blah 

%% Initialise
clear
clc

%% Load data
load('true_data', 'MM', 'X', 'tSol', 'true_data', 'v', 'p', 'u')

%% Measurements with Variance
% The function measureReal artificially corrupts the true data
variance = [0.05 5]; 

% Variance analysis analysis
for i = 1:2
    [measured_data, time] = measureReal(MM, X, v, u, p, tSol, variance(i));
    Xhat = zeros(25,1001);
    XB   = zeros(4,1001);

    % Set Up Matrices
    X0 = zeros(25,1);
    [Y, index] = measurements_Y(0, measured_data);
    W = varianceMatrix(length(index), variance(i));

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

    % Error Metrics
    % Mean Absolute Percentage Error
    mapeM(i,:)    = mean(100*abs((true_data.XB(:,100:end) - measured_data.XB(:,100:end))./true_data.XB(:,100:end)));
    mape_avm(i,:) = mean(100*abs((true_data.XB(:,100:end) - XB(1,100:end))./true_data.XB(:,100:end)));
    
    clear measured_data
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
        index = (1:25); 
         
    elseif v == 1 % Remove >> Y4
        Y = [measured_data.L1; measured_data.L2; measured_data.L3; measured_data.L4; measured_data.LB;...
             measured_data.LD; measured_data.LR; measured_data.LF; measured_data.V0; measured_data.V1;...
             measured_data.V2; measured_data.V3; measured_data.V4; measured_data.X2; measured_data.X1;...
             measured_data.X3; measured_data.X4; measured_data.XB; measured_data.XD; measured_data.XF;...
             measured_data.Y0; measured_data.Y1; measured_data.Y2; measured_data.Y3];  
        index = (1:24); 
         
    elseif v == 2 % Remove >> L4, X1, X4
        Y = [measured_data.L1; measured_data.L2; measured_data.L3; measured_data.LB;...
             measured_data.LD; measured_data.LR; measured_data.LF; measured_data.V0; measured_data.V1;...
             measured_data.V2; measured_data.V3; measured_data.V4; measured_data.X2;...
             measured_data.X3; measured_data.XB; measured_data.XD; measured_data.XF;...
             measured_data.Y0; measured_data.Y1; measured_data.Y2; measured_data.Y3; measured_data.Y4];
        index = [1:3,5:13,15:16,18:25]; 
         
    elseif v == 3 % Remove >> L4, V3, X1, X4
        Y = [measured_data.L1; measured_data.L2; measured_data.L3; measured_data.LB;...
             measured_data.LD; measured_data.LR; measured_data.LF; measured_data.V0; measured_data.V1;...
             measured_data.V2; measured_data.V4; measured_data.X2;...
             measured_data.X3; measured_data.XB; measured_data.XD; measured_data.XF;...
             measured_data.Y0; measured_data.Y1; measured_data.Y2; measured_data.Y3; measured_data.Y4];
        index = [1:3,5:11,13,15:16,18:25]; 
         
    elseif v == 4 % Remove >> L4, V3, X1, X4, Y2
        Y = [measured_data.L1; measured_data.L2; measured_data.L3; measured_data.LB;...
             measured_data.LD; measured_data.LR; measured_data.LF; measured_data.V0; measured_data.V1;...
             measured_data.V2; measured_data.V4; measured_data.X2;...
             measured_data.X3; measured_data.XB; measured_data.XD; measured_data.XF;...
             measured_data.Y0; measured_data.Y1; measured_data.Y3; measured_data.Y4];
        index = [1:3,5:11,13,15:16,18:22,24:25]; 
        
    end
end