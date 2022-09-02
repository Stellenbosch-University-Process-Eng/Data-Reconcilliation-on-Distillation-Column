%% Initialise
clear
clc

%% Define time period
t = linspace(0,1000,1000);

%% Define Parameters 

% Need weir height and correct volatility

p.N = 4;        % ~, Number of trays 
p.alpha = 2.4;  % ~, Relative volatility
p.yy = 1;       % ~, Activity coefficient 
p.kw = 5;      % ~, Weir constant
p.lw = 0;       % m, Weir height
p.pm = 11;        % moles/m^3, Density >> (876 kg/m3 * 1000 g/kg / 78.11 g/mol) / 1000 mol/kmol
p.A  = 3;       % m^2, Area 
p.kr = 0.5;     % ~, Reboiler constant -- Heat vaporisation

%% Define exogenous variables
% Feed variables
u.LF = @(t) 10 + 0*(t > 500);       % mol/min, Feed liquid molar flowrate
u.XF = @(t) 0.5 - 0*(t > 300);              % ~, Feed liquid molar fraction 

% Desired ratios 
u.R = @(t) 2.5 + 0*(t > 100);     % ~, Reflux ratio
u.B = @(t) 2 + 0*t;                 % ~, Boilup ratio

% Heat transfer rates across trays
for n = 1 : p.N
    u.Q{n} = @(t) 0 + 0*t;          % kJ/mol, Heat transfer rate for each tray
end

u.Freb = @(t) 2 + 0*t;              % mol/min, Boiler heating fluid molar flowrate

%% Define intial conidtions - Molar Holdup
% Initial conditions of the molar holdup ODEs
DV0 = [ones(p.N,1); zeros(6,1)];

%% Simulate ODEs - Molar Holdup
% This solves the molar holdup ODEs
sol = ode45(@(t, x) simulate_ODEs(t, x, u, p), [0 1000], DV0);
DV = sol.y;
tSol = sol.x;
v = intermediaries(tSol, DV, u, p);

% Change into desired vector format & naming convention
MM = DV(1:p.N,:);
X  = DV(p.N+1:end,:);
tSol = tSol';

%% Plot results
% Plot Molar Holdup
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
xlabel('Time (s)'); ylabel('Liquid molar flowrate')
labelsL = cell(1,p.N);
for n = 1:p.N
    labelsL{n} = "L"+num2str(n);
end
labelsL{end+1} = "LB";
labelsL{end+1} = "LD";
labelsL{end+1} = "LR";
legend(labelsL, 'location', 'best')

%% Measure true data 
true_data = measureReal(MM, X, v, u, p, tSol, 0);

%% Save data
save('true_data', 'MM', 'X', 'tSol', 'true_data', 'v', 'u', 'p')


