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
DV0 = [1;1;1;1;0;0;0;0;0;0];

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

%% Measurements for mol fractions
% m.XB = X(:,p.N+1);
% m.XD = X(:,p.N+2);
% 
% % Define fields for the desired measurements
% meas.fields = {'XB','XD','LD'};
% 
% % Define measurement structure
% meas.XB  = struct('func', @(t, m, u, vM) m.XB, 'var', 0.1, 'T', 1,  'D', 0);
% meas.XD  = struct('func', @(t, m, u, vM) m.XD, 'var', 0.1, 'T', 1,  'D', 0);
% meas.LD  = struct('func', @(t, m, u, vM) vM.LD, 'var', 0.1, 'T', 2,  'D', 0);
% 
% y = measurements(tSol, m, u, v, meas);
% ytB = y.XB.Time(:,1:end)';
% ytD = y.XD.Time(:,1:end)';
% ytL = y.LD.Time(:,1:end)';
% yB  = y.XB.Data(:,1:end)';
% yD  = y.XD.Data(:,1:end)';
% yL  = y.LD.Data(:,1:end)';

%% Plot results
% subplot(1,2,1)
% plot(t, MM);
% xlabel('Time (s)'); ylabel('Liquid holdup (mol)')
% labelsM = {"","","",""};
% for n = 1:p.N
%         labelsM{n} = "MM" + num2str(n);
% end
% legend(labelsM, 'location', 'best')

% subplot(1,2,2)

% plot(tSol, X)
% hold on
% 
% plot(ytB, yB, ytD, yD)
% 
% xlabel('Time (s)'); ylabel('Liquid mol fraction')
% labelsX = {};
% for n = 1:p.N
%     labelsX{n} = "X" + num2str(n);
% end
% labelsX{p.N+1} = "XB + Noise";
% labelsX{p.N+2} = "XD + Noise";
% legend(labelsX, 'location', 'best')
% hold off

%% Measurements for flowrates
% Define measurements
m.L1 = v.L(1,:)';
m.L2 = v.L(2,:)';
m.L3 = v.L(3,:)';
m.L4 = v.L(4,:)';
m.LB = v.LB';
m.LD = v.LD';
m.LR = v.LR';

m.V0 = v.V0';
m.V1 = v.V(1,:)';
m.V2 = v.V(2,:)';
m.V3 = v.V(3,:)';
m.V4 = v.V(4,:)';

% Define measurement fields
meas.fields = {'L1','L2','L3','L4','LB','LD','LR','V0','V1','V2','V3','V4'};

% Define measurement structure
meas.L1 = struct('func', @(t,m,u,v) m.L1, 'var', 0.1, 'T', 1, 'D', 0);
meas.L2 = struct('func', @(t,m,u,v) m.L2, 'var', 0.1, 'T', 1, 'D', 0);
meas.L3 = struct('func', @(t,m,u,v) m.L3, 'var', 0.1, 'T', 1, 'D', 0);
meas.L4 = struct('func', @(t,m,u,v) m.L4, 'var', 0.1, 'T', 1, 'D', 0);
meas.LB = struct('func', @(t,m,u,v) m.LB, 'var', 0.1, 'T', 1, 'D', 0);
meas.LD = struct('func', @(t,m,u,v) m.LD, 'var', 0.1, 'T', 1, 'D', 0);
meas.LR = struct('func', @(t,m,u,v) m.LR, 'var', 0.1, 'T', 1, 'D', 0);

meas.V0 = struct('func', @(t,m,u,v) m.V0, 'var', 0.1, 'T', 1, 'D', 0);
meas.V1 = struct('func', @(t,m,u,v) m.V1, 'var', 0.1, 'T', 1, 'D', 0);
meas.V2 = struct('func', @(t,m,u,v) m.V2, 'var', 0.1, 'T', 1, 'D', 0);
meas.V3 = struct('func', @(t,m,u,v) m.V3, 'var', 0.1, 'T', 1, 'D', 0);
meas.V4 = struct('func', @(t,m,u,v) m.V4, 'var', 0.1, 'T', 1, 'D', 0);

% Call measurement function
y = measurements(tSol, m, u, v, meas);
yt  = y.L1.Time;
yL1 = y.L1.Data(:,1:end)';
yL2 = y.L2.Data(:,1:end)';
yL3 = y.L3.Data(:,1:end)';
yL4 = y.L4.Data(:,1:end)';
yLB = y.LB.Data(:,1:end)';
yLD = y.LD.Data(:,1:end)';
yLR = y.LR.Data(:,1:end)';

yV0 = y.V0.Data(:,1:end)';
yV1 = y.V1.Data(:,1:end)';
yV2 = y.V2.Data(:,1:end)';
yV3 = y.V3.Data(:,1:end)';
yV4 = y.V4.Data(:,1:end)';


% % Define fields for the desired measurements
% meas.fields = {'XB','XD','LD'};
% 
% % Define measurement structure
% meas.XB  = struct('func', @(t, m, u, vM) m.XB, 'var', 0.1, 'T', 1,  'D', 0);
% meas.XD  = struct('func', @(t, m, u, vM) m.XD, 'var', 0.1, 'T', 1,  'D', 0);
% meas.LD  = struct('func', @(t, m, u, vM) vM.LD, 'var', 0.1, 'T', 2,  'D', 0);
% 
% y = measurements(tSol, m, u, v, meas);
% ytB = y.XB.Time(:,1:end)';
% ytD = y.XD.Time(:,1:end)';
% ytL = y.LD.Time(:,1:end)';
% yB  = y.XB.Data(:,1:end)';
% yD  = y.XD.Data(:,1:end)';
% yL  = y.LD.Data(:,1:end)';
