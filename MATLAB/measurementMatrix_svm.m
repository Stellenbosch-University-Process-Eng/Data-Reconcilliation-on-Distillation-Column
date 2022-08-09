function m = measurementMatrix_svm(v, measured_data)
% This function redefines the measurement matrix, i.e the measurement
% matrix without the unmeasured variables. Thus, it generates the matrix
% for some variables measured.
% Below is a key which specifies which variables were 'not measured'

% Key:
% v == 1 >> L1
% v == 2 >> L1 V4
% v == 3 >> L1 L2 V4
% v == 4 >> L1 L2 V3 V4

    if v == 1
        m = [measured_data.L2; measured_data.L3; measured_data.L4; measured_data.LB;...
             measured_data.LD; measured_data.LR; measured_data.V0; measured_data.V1;...
             measured_data.V2; measured_data.V3; measured_data.V4; measured_data.LF];
    elseif v == 2
        m = [measured_data.L2; measured_data.L3; measured_data.L4; measured_data.LB;...
             measured_data.LD; measured_data.LR; measured_data.V0; measured_data.V1;...
             measured_data.V2; measured_data.V3; measured_data.LF];
    elseif v == 3
        m = [measured_data.L3; measured_data.L4; measured_data.LB;...
             measured_data.LD; measured_data.LR; measured_data.V0; measured_data.V1;...
             measured_data.V2; measured_data.V3; measured_data.LF];
    elseif v == 4
        m = [measured_data.L3; measured_data.L4; measured_data.LB;...
             measured_data.LD; measured_data.LR; measured_data.V0; measured_data.V1;...
             measured_data.V2; measured_data.LF];
    end
    
end