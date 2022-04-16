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
u.LF = @(t) 5 + 0.5*(t > 300);

%  Desired reflux 
u.LR = @(t) 13.5 + 2*(t > 100);

%  Heat transfer rates across trays
u.Q1 = @(t) 0 + 0.5*(t > 200);
u.Q2 = @(t) 0 + 0.5*(t > 300);
u.Q3 = @(t) 0 + 0.5*(t > 400);
u.Q4 = @(t) 0 + 0.5*(t > 500);
u.Freb = @(t) 2 + 0*t;

%% Define intial conidtions
p.fields = ["MM1", "MM2", "MM3", "MM4"];
x0.MM1 = 1; x0.MM2 = 1; x0.MM3 = 1; x0.MM4 = 1;
x0_vec = structure_2_vector(x0, p.fields);

%% Simulate ODEs
sol = ode45(@(t, x) simulate_ODEs(t, x, u, p), [0 1000], x0_vec);
x.MM1 = sol.y(1,:)'; x.MM2 = sol.y(2,:)'; x.MM3 = sol.y(3,:)'; x.MM4 = sol.y(4,:)';
v = intermediaries(sol.x, x, u, p);


