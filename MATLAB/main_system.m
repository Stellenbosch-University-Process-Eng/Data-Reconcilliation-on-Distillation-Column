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
MM0 = ones((p.N*2)+2, 1);

%% Simulate ODEs - Molar Holdup
% This solves the molar holdup ODEs
solM = ode45(@(t, x) simulate_ODEs(t, x, u, p), [0 1000], MM0);
MM = solM.y';
t = solM.x';
vM = intermediaries(t, MM, u, p);

%% Plot results
subplot(1,2,1)
plot(t, MM(:,1:p.N));
xlabel('Time (s)'); ylabel('Liquid holdup (mol)')
labelsM = {};
for n = 1:p.N
        labelsM{n} = "MM" + num2str(n);
end
legend(labelsM, 'location', 'best')

subplot(1,2,2)
plot(t, MM(:,(p.N+1):end))
xlabel('Time (s)'); ylabel('Liquid mol fraction)')
labelsX = {};
for n = 1:p.N
    labelsX{n} = "X" + num2str(n);
end
labelsX{p.N+1} = "XB";
labelsX{p.N+2} = "XD";
legend(labelsX, 'location', 'best')