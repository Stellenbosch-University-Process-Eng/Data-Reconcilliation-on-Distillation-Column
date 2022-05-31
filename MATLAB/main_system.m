%% Initialise
clear
clc

%% Define time period
t = linspace(0,1000,1000);

%% Define Parameters 
p.N = 4;        % ~, Number of trays 
p.alpha = 2.4;  % ~, Relative volatility
% p.yy = 2500;    % ~, Activity coefficient 
% p.kw = 0.5;     % ~, Weir constant
% p.lw = 0.5;     % m, Weir height
% p.pm = 0.5;     % moles/m^3, Density
% p.A  = 2;       % m^2, Area 
% p.kr = 0.5;     % ~, Reboiler constant

%% Define exogenous variables
% Feed variables
u.LF = @(t) 10 + 1*(t > 300);       % mol/min, Feed liquid molar flowrate
u.XF = @(t) 0.5 + 0*t;              % ~, Feed liquid molar fraction 

% Desired reflux 
u.R = @(t) 2.5 + 0.2*(t > 100);     % ~, Reflux ratio

% Heat transfer rates across trays
for n = 1 : p.N
    u.Q{n} = @(t) 0 + 0*t;          % kJ/mol, Heat transfer rate for each tray
end

u.Freb = @(t) 2 + 0*t;              % mol/min, Boiler heating fluid molar flowrate

%% Define intial conidtions - Molar Holdup
% Initial conditions of the molar holdup ODEs
DV0 = [ones(p.N,1); zeros(p.N+2,1)];

%% Simulate ODEs - Molar Holdup
% This solves the molar holdup ODEs
sol = ode45(@(t, x) simulate_ODEs(t, x, u, p), [0 1000], DV0);
DV = sol.y;
tSol = sol.x;
v = intermediaries(tSol, DV, u, p);

% Change into desired vector format & naming convention
MM = DV(1:p.N,:)';
X  = DV(p.N+1:end,:)';
tSol = tSol';

%% Measurements for flowrates
% Define measurements
for i = 1:p.N
    m.("L"+num2str(i)) = v.L(i,:)'; 
end
m.LB = v.LB';
m.LD = v.LD';
m.LR = v.LR';

m.V0 = v.V0';
for i = 1:p.N
    m.("V"+num2str(i)) = v.V(i,:)'; 
end

% Define measurement fields
for i = 1:p.N
    meas.fields{i} = "L"+num2str(i);
end
meas.fields{end+1} = "LB";
meas.fields{end+1} = "LD";
meas.fields{end+1} = "LR";

meas.fields{end+1} = "V0";
for i = 1:p.N
    meas.fields{end+1} = "V"+num2str(i);
end

% Define measurement structure
for i = 1:p.N
    meas.("L"+num2str(i)) = struct('func', @(t,m,u,v) m.("L"+num2str(i)), 'var', 0.1, 'T', 1, 'D', 0);
end
meas.LB = struct('func', @(t,m,u,v) m.LB, 'var', 0.1, 'T', 1, 'D', 0);
meas.LD = struct('func', @(t,m,u,v) m.LD, 'var', 0.1, 'T', 1, 'D', 0);
meas.LR = struct('func', @(t,m,u,v) m.LR, 'var', 0.1, 'T', 1, 'D', 0);

meas.V0 = struct('func', @(t,m,u,v) m.V0, 'var', 0.1, 'T', 1, 'D', 0);
for i = 1:p.N
    meas.("V"+num2str(i)) = struct('func', @(t,m,u,v) m.("V"+num2str(i)), 'var', 0.1, 'T', 1, 'D', 0);
end

% Call measurement function
y = measurements(tSol, m, u, v, meas);
time = y.L1.Time;
for i = 1:p.N
    measured_data.("L"+num2str(i)) = y.("L"+num2str(i)).Data(:,1:end)';
end
measured_data.LB = y.LB.Data(:,1:end)';
measured_data.LD = y.LD.Data(:,1:end)';
measured_data.LR = y.LR.Data(:,1:end)';

measured_data.V0 = y.V0.Data(:,1:end)';
for i = 1:p.N
    measured_data.("V"+num2str(i)) = y.("V"+num2str(i)).Data(:,1:end)';
end


%% Plot results
% Plot Molar Holup
subplot(3,1,1)
plot(tSol, MM);
labelsM = cell(1,p.N);
for n = 1:p.N
        labelsM{n} = "MM" + num2str(n);
end
xlabel('Time (s)'); ylabel('Liquid holdup (mol)')
legend(labelsM, 'location', 'best')

% Plot Molar Fractions
subplot(3,1,2)
plot(tSol, X)
labelsX = cell(1,p.N);
for n = 1:p.N
    labelsX{n} = "X" + num2str(n);
end
xlabel('Time (s)'); ylabel('Liquid mol fraction')
labelsX{end+1} = "XB";
labelsX{end+1} = "XD";
legend(labelsX, 'location', 'best')

% Plot Liquid Flowrates
subplot(3,1,3)
plot(tSol, v.L', tSol, v.LB', 'r', tSol, v.LD', tSol, v.LR', 'b')
hold on
plot(time, measured_data.LB, 'r', time, measured_data.LR, 'b')
hold off
xlabel('Time (s)'); ylabel('Liquid molar flowrate')
labelsL = cell(1,p.N);
for n = 1:p.N
    labelsL{n} = "L"+num2str(n);
end
labelsL{end+1} = "LB";
labelsL{end+1} = "LD";
labelsL{end+1} = "LR";
legend(labelsL, 'location', 'best')




