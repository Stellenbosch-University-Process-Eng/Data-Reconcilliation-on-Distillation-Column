function [measured_data time] = measureReal(v, u, p, tSol, input)
% This function takes in the generated values of the model and subsequently
% 'measures' the true values. This is done so that the dimensions of the true
% values conform to the dimensions of the actual measurements (i.e. the
% artificially corrupted measurements).

%%  Define measurements
    % Liquid measurements
    for i = 1:p.N
        m.("L"+num2str(i)) = v.L(i,:)';
    end
    m.LB = v.LB';
    m.LD = v.LD';
    m.LR = v.LR';
    m.LF = u.LF(tSol);

    % Vapour measurements
    m.V0 = v.V0';
    for i = 1:p.N
        m.("V"+num2str(i)) = v.V(i,:)';
    end

%% Define measurement fields
    % Liquid fields
    for i = 1:p.N
        meas.fields{i} = "L"+num2str(i);
    end
    meas.fields{end+1} = "LB";
    meas.fields{end+1} = "LD";
    meas.fields{end+1} = "LR";
    meas.fields{end+1} = "LF";

    % Vapour fields
    meas.fields{end+1} = "V0";
    for i = 1:p.N
        meas.fields{end+1} = "V"+num2str(i);
    end

%% Define measurement structure
    % Liquid structure
    for i = 1:p.N
        meas.("L"+num2str(i)) = struct('func', @(t,m,u,v) m.("L"+num2str(i)), 'var', input, 'T', 1, 'D', 0);
    end
    meas.LB = struct('func', @(t,m,u,v) m.LB, 'var', input, 'T', 1, 'D', 0);
    meas.LD = struct('func', @(t,m,u,v) m.LD, 'var', input, 'T', 1, 'D', 0);
    meas.LR = struct('func', @(t,m,u,v) m.LR, 'var', input, 'T', 1, 'D', 0);
    meas.LF = struct('func', @(t,m,u,v) m.LF, 'var', input, 'T', 1, 'D', 0);

    % Vapour structure
    meas.V0 = struct('func', @(t,m,u,v) m.V0, 'var', input, 'T', 1, 'D', 0);
    for i = 1:p.N
        meas.("V"+num2str(i)) = struct('func', @(t,m,u,v) m.("V"+num2str(i)), 'var', input, 'T', 1, 'D', 0);
    end

%% Call measurement function
    y = measurements(tSol, m, u, v, meas);
    time = y.L1.Time;
    for i = 1:p.N
        measured_data.("L"+num2str(i)) = y.("L"+num2str(i)).Data(:,1:end);
    end
    measured_data.LB = y.LB.Data(:,1:end);
    measured_data.LD = y.LD.Data(:,1:end);
    measured_data.LR = y.LR.Data(:,1:end);
    measured_data.LF = y.LF.Data(:,1:end);

    measured_data.V0 = y.V0.Data(:,1:end);
    for i = 1:p.N
        measured_data.("V"+num2str(i)) = y.("V"+num2str(i)).Data(:,1:end);
    end

end

