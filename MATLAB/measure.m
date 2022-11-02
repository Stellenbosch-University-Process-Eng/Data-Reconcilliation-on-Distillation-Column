function [measured_data, time] = measureReal(MM, X, v, u, p, tSol, input, option)
% This function takes in the generated values of the model and subsequently
% 'measures' the true values, i.e artificially corrupts the true data. This
% is done to mimic real life measurements of process variables, which will
% inherently contain random errors. Note, this function functions exactly
% the same as measureReal, however, this function allows to measure the
% flowrates and mole fractions seperately. 


%% Choose Variables To Measure
    if option == 1
        % Define measurements
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

        % Molar holdup measurements
        for i = 1:p.N
            m.("MM"+num2str(i)) = MM(i,:)';
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

        % Molar holdup measurements
        for i = 1:p.N
            meas.fields{end+1} = "MM"+num2str(i);
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

        % Molar holdup measurements 
        for i = 1:p.N
            meas.("MM"+num2str(i)) = struct('func', @(t,m,u,v) m.("MM"+num2str(i)), 'var', input, 'T', 1, 'D', 0);
        end

    %% Call measurement function
        y = measurements(tSol, m, u, v, meas);
        time = y.L1.Time;

        % Liquid
        for i = 1:p.N
            measured_data.("L"+num2str(i)) = y.("L"+num2str(i)).Data(:,1:end);
        end
        measured_data.LB = y.LB.Data(:,1:end);
        measured_data.LD = y.LD.Data(:,1:end);
        measured_data.LR = y.LR.Data(:,1:end);
        measured_data.LF = y.LF.Data(:,1:end);

        % Vapour
        measured_data.V0 = y.V0.Data(:,1:end);
        for i = 1:p.N
            measured_data.("V"+num2str(i)) = y.("V"+num2str(i)).Data(:,1:end);
        end

        % Molar holdup
        for i = 1:p.N
            measured_data.("MM"+num2str(i)) = y.("MM"+num2str(i)).Data(:,1:end);
        end
        
    else
        % Define measurements - 2nd Loop
        % Molar liquid fraction measurements
        for i = 1:p.N
            m.("X"+num2str(i)) = X(i,:)';
        end
        m.XB = X(5,:)';
        m.XD = X(6,:)';
        m.XF = u.XF(tSol);

        % Molar vapour fraction measurements
        m.Y0 = v.Y0';
        for i = 1:p.N
            m.("Y"+num2str(i)) = v.Y(i,:)';
        end

    %% Define measurement fields
        % Molar liquid fraction measurements
        for i = 1:p.N
            meas.fields{i} = "X"+num2str(i);
        end
        meas.fields{end+1} = "XB";
        meas.fields{end+1} = "XD";
        meas.fields{end+1} = "XF";

        % Molar vapour fraction fields
        meas.fields{end+1} = "Y0";
        for i = 1:p.N
            meas.fields{end+1} = "Y"+num2str(i);
        end

    %% Define measurement structure
        % Molar liquid fraction measurements
        for i = 1:p.N
            meas.("X"+num2str(i)) = struct('func', @(t,m,u,v) m.("X"+num2str(i)), 'var', input, 'T', 1, 'D', 0);
        end
        meas.XB = struct('func', @(t,m,u,v) m.XB, 'var', input, 'T', 1, 'D', 0);
        meas.XD = struct('func', @(t,m,u,v) m.XD, 'var', input, 'T', 1, 'D', 0);
        meas.XF = struct('func', @(t,m,u,v) m.XF, 'var', input, 'T', 1, 'D', 0);

        % Molar vapour fraction structure
        meas.Y0 = struct('func', @(t,m,u,v) m.Y0, 'var', input, 'T', 1, 'D', 0);
        for i = 1:p.N
            meas.("Y"+num2str(i)) = struct('func', @(t,m,u,v) m.("Y"+num2str(i)), 'var', input, 'T', 1, 'D', 0);
        end

    %% Call measurement function
        y = measurements(tSol, m, u, v, meas);
        time = y.X1.Time;

        % Molar liquid fractions
        for i = 1:p.N
            measured_data.("X"+num2str(i)) = y.("X"+num2str(i)).Data(:,1:end);
        end
        measured_data.XB = y.XB.Data(:,1:end);      
        measured_data.XD = y.XD.Data(:,1:end);
        measured_data.XF = y.XF.Data(:,1:end);

        for i = 1:length(time)

            for j = 1:p.N
                if measured_data.("X"+num2str(j))(:,i) < 0
                    measured_data.("X"+num2str(j))(:,i) = 0;
                elseif measured_data.("X"+num2str(j))(:,i) > 1
                    measured_data.("X"+num2str(j))(:,i) = 1;
                end
            end

            if measured_data.XB(:,i) < 0
                measured_data.XB(:,i) = 0;
            elseif measured_data.XB(:,i) > 1
                measured_data.XB(:,i) = 1;
            end

            if measured_data.XD(:,i) < 0
                measured_data.XD(:,i) = 0;
            elseif measured_data.XD(:,i) > 1
                measured_data.XD(:,i) = 1;
            end

            if measured_data.XF(:,i) < 0
                measured_data.XF(:,i) = 0;
            elseif measured_data.XF(:,i) > 1
                measured_data.XF(:,i) = 1;
            end
        end  

        % Molar vapour fractions
        measured_data.Y0 = y.Y0.Data(:,1:end);
        for i = 1:p.N
            measured_data.("Y"+num2str(i)) = y.("Y"+num2str(i)).Data(:,1:end);
        end

        for i = 1:length(time)

            for j = 1:p.N
                if measured_data.("Y"+num2str(j))(:,i) < 0
                    measured_data.("Y"+num2str(j))(:,i) = 0;
                elseif measured_data.("Y"+num2str(j))(:,i) > 1
                    measured_data.("Y"+num2str(j))(:,i) = 1;
                end
            end

            if measured_data.Y0(:,i) < 0
                measured_data.Y0(:,i) = 0;
            elseif measured_data.Y0(:,i) > 1
                measured_data.Y0(:,i) = 1;
            end

        end
    
    end
    
end

