function LB = generateLB_svm(v, measured_data, var)
% This function generates the reconciled estimates of the variable LB based
% on the number of unmeasured variables, v. This is achieved by firstly
% generating the necessary Ax & Au matrices. Thereafter, the required
% projection matrix is calculated, which is subsequently used to reconcile
% the LB variable.

% Below is key which specifies which variables were 'not measured'
% Key:
% v == 1 >> L1
% v == 2 >> L1 V4
% v == 3 >> L1 L2 V4
% v == 4 >> L1 L2 V3 V4
 
    L1 = [+1;-1;+0;+0;+0;+0];
    L2 = [+0;+1;-1;+0;+0;+0];
    L3 = [+0;+0;+1;-1;+0;+0];
    L4 = [+0;+0;+0;+1;-1;+0];
    LB = [-1;+0;+0;+0;+0;+0];
    LD = [+0;+0;+0;+0;+0;-1];
    LR = [+0;+0;+0;+0;+1;-1];
    V0 = [-1;+1;+0;+0;+0;+0];
    V1 = [+0;-1;+1;+0;+0;+0];
    V2 = [+0;+0;-1;+1;+0;+0];
    V3 = [+0;+0;+0;-1;+1;+0]; 
    V4 = [+0;+0;+0;+0;-1;+1]; 
    LF = [+0;+0;+1;+0;+0;+0];

    if v == 1
        % Generate Matrix
        Ax = [L2 L3 L4 LB LD LR V0 V1 V2 V3 V4 LF];
        Au = L1;
        
        % Compute Projection Matrix
        [Q, ~] = qr(Au);
        s = 1;
        Q2 = Q(:, s+1:end);
        P = Q2';
        
        % Redefine measurement & variance matrix
        m = measurementMatrix_svm(v, measured_data);
        W = varianceMatrix(12, var);
        
        % Perform data reconcialiation
        xhat_1 = m - (W*(P*Ax)')*(((P*Ax)*W*(P*Ax)')\((P*Ax)*m));
        LB = xhat_1(4,:);
        
    elseif v == 2
        % Generate Matrix
        Ax = [L2 L3 L4 LB LD LR V0 V1 V2 V3 LF];
        Au = [L1 V4];

        % Compute Projection Matrix
        [Q, ~] = qr(Au);
        s = 2;
        Q2 = Q(:, s+1:end);
        P = Q2';
        
        % Redefine measurement matrix
        m = measurementMatrix_svm(v, measured_data);
        W = varianceMatrix(11, var);
        
        % Perform data reconcialiation
        xhat_2 = m - (W*(P*Ax)')*(((P*Ax)*W*(P*Ax)')\((P*Ax)*m));
        LB = xhat_2(4,:);
        
    elseif v == 3
        % Generate Matrix
        Ax = [L3 L4 LB LD LR V0 V1 V2 V3 LF];
        Au = [L1 L2 V4];
       
        % Compute Projection Matrix
        [Q, ~] = qr(Au);
        s = 3;
        Q2 = Q(:, s+1:end);
        P = Q2';
        
        % Redefine measurement matrix
        m = measurementMatrix_svm(v, measured_data);
        W = varianceMatrix(10, var);
        
        % Perform data reconcialiation
        xhat_3 = m - (W*(P*Ax)')*(((P*Ax)*W*(P*Ax)')\((P*Ax)*m));
        LB = xhat_3(3,:);
        
    elseif v == 4
        % Generate Matrix
        Ax = [L3 L4 LB LD LR V0 V1 V2 LF];
        Au = [L1 L2 V3 V4];
        
        % Compute Projection Matrix
        [Q, ~] = qr(Au);
        s = 4;
        Q2 = Q(:, s+1:end);
        P = Q2';
        
        % Redefine measurement matrix
        m = measurementMatrix_svm(v, measured_data);
        W = varianceMatrix(9, var);
        
        % Perform data reconcialiation
        xhat_4 = m - (W*(P*Ax)')*(((P*Ax)*W*(P*Ax)')\((P*Ax)*m));
        LB = xhat_4(3,:);
        
    end
end