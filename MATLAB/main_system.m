%% Initialise
clear
clc
clf

%% Define time period
t = linspace(0,1000,1000);

%% Define Parameters 
p.N = 4;        % ~, Number of trays. 
p.alpha = 2.4;  % ~, Relative volatility
p.yy = 2500;    % ~, Activity coefficient - go do research
p.kw = 0.5;     % ~, No idea
p.lw = 0.5;     % ~, No idea
p.pm = 0.5;     % ~, Density
p.A  = 2;       % m^2, Area 
p.kr = 0.5;     % ~, Reboiler constant

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
u.Qreb = @(t) p.kr*u.Freb(t);     % kJ/mol, Reboiler duty

%% Define intial conidtions - Molar Holdup
% Initial conditions of the molar holdup ODEs
MM0 = ones(p.N+2, 1);

%% Simulate ODEs - Molar Holdup
% This solves the molar holdup ODEs
solM = ode45(@(t, x) simulate_ODEs(t, x, u, p), [0 1000], MM0);
MM = solM.y;
t = solM.x;
vM = intermediaries(t, MM, u, p);

%% Plot results
% #TML: you should plot your results to check if they make sense!
plot(t, MM)
xlabel('Time (s)'); ylabel('Liquid holdup (mol)')
labels = {};
for n = 1:(p.N+2)
    labels{n} = "MM" + num2str(n);
end
legend(labels, 'location', 'best')
%% Define initial conditions - Concentrations
% #TML: you need to solve for your mole fractions and hold-ups
% simultaneously. For discussion during meeting

% % Initial conditions of the liquid mole fractions
% p.fieldsX = ["X1", "X2", "X3", "X4", "XB", "XD"];
% x0X.X1 = 0.1; x0X.X2 = 0.25; x0X.X3 = 0.5; x0X.X4 = 0.8; x0X.XB = 0.02; x0X.XD = 0.98;
% x0X_vec = structure_2_vector(x0X, p.fieldsX);
% 
% %% Simulate ODEs - Concentrations
% % This solves the liquid mole fraction ODEs
% sol1 = ode45(@(t, y) simulate_ODEs1(t, x, vM, u, p), [0 1000], x0X_vec)
