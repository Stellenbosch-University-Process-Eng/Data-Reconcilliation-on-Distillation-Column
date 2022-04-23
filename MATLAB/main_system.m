%% Initialise
clear
clc 

%% Define time period
t = linspace(0,1000,1000);

%% Define Parameters 
% Will be leaving this for now. The parameters don't affect the solvability
% of the system.

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
u.Q1 = @(t) 0 + 0*t;
u.Q2 = @(t) 0 + 0*t;
u.Q3 = @(t) 0 + 0*t;
u.Q4 = @(t) 0 + 0*t;
u.Freb = @(t) 2 + 0*t;

%% Define intial conidtions
% Initial conditions of the molar holdup ODEs
p.fieldsM = ["MM1", "MM2", "MM3", "MM4"];
x0M.MM1 = 1; x0M.MM2 = 1; x0M.MM3 = 1; x0M.MM4 = 1;
x0M_vec = structure_2_vector(x0M, p.fieldsM);

%% Simulate ODEs
% This solves the molar holdup ODEs
solM = ode45(@(t, x) simulate_ODEs(t, x, u, p), [0 1000], x0M_vec);
m.MM1 = solM.y(1,:)'; m.MM2 = solM.y(2,:)'; m.MM3 = solM.y(3,:)'; m.MM4 = solM.y(4,:)';
vM = intermediaries(solM.x, m, u, p);

% %% Define initial conditions
% % Initial conditions of the liquid mole fractions
% p.fieldsX = ["X1", "X2", "X3", "X4", "XB", "XD"];
% x0X.X1 = 0.1; x0X.X2 = 0.25; x0X.X3 = 0.5; x0X.X4 = 0.8; x0X.XB = 0.02; x0X.XD = 0.98;
% x0X_vec = structure_2_vector(x0X, p.fieldsX);
% 
% %% Simulate ODEs
% % This solves the liquid mole fraction ODEs
% sol1 = ode45(@(t, y) simulate_ODEs1(t, x, vM, u, p), [0 1000], x0X_vec)
% 



