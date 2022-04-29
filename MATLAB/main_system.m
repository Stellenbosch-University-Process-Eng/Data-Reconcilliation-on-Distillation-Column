%% Initialise
clear
clc
clf

%% Define time period
t = linspace(0,1000,1000);

%% Define Parameters 
% Will be leaving this for now. The parameters don't affect the solvability
% of the system.

p.N = 4;      % ~, number of trays. #TML:note that I provide units (in this case none, ~) and a description

%% Define exogenous variables
%  Feed variables
u.LF = @(t) 10 + 1*(t > 300);
u.XF = @(t) 0.5 + 0*t;

%  Desired reflux 
u.LR = @(t) 8.53 + 2*(t > 100);

%  Molar Holdup
u.MMB = @(t) 10 + 0*t;
u.MMD = @(t) 10 + 0*t;

%  Heat transfer rates across trays
for n = 1 : p.N
    u.Q{n} = @(t) 0 + 0*t;      % #TML: Cells { } are a useful way of storing things other than numbers, like functions
end
u.Freb = @(t) 2 + 0*t;

%% Define intial conidtions - Molar Holdup
% Initial conditions of the molar holdup ODEs
% #TML: I suggest simplifying things, don't use structures for your state
% variables
MM0 = ones(p.N, 1);

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
for n = 1:p.N
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




