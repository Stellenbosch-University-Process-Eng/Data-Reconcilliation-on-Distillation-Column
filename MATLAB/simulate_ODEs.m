function dxdt = simulate_ODEs(t, x, u, p)
% This fucntion simulates the molar holdup ODEs

% Define dependent variables
    DV = x(1:(p.N*2+2));        % Depedent Variables
    MM = DV(1:p.N);             % mol/min, Molar holdup
    X  = DV(p.N+1:end);         % ~, Liquid mole fraction

% Caculate intermediaries
    v  = intermediaries(t, DV, u, p);  
    
% Calculate Molar holup derivatives 
% Formula:
% dMM_i/dt = L_i+1 - L_i + L_fi - Qi/lambda
    ddt_MM = zeros(p.N, 1);
    for n = 1:p.N-1
        ddt_MM(n) = v.L(n+1,:) - v.L(n,:) - u.Q{n}(t);     % mol/min, Molar holdup - MM1:MM3
    end
    ddt_MM(2) = ddt_MM(2,:) + u.LF(t);                   % mol/min, Added feed flowrate to MM2
    ddt_MM(p.N) = v.LR - v.L(p.N,:) - u.Q{p.N}(t);       % mol/min, Molar holdup - MM4

% Calculate Liquid fracion derivatives
% dX_i/dt = L_i+1 * (X_i+1 - X_i)  +  L_fi * (X_fi - X_i)  -  V_i * Y_i  +
%           V_i-1 * Y_i-1  +  (Q_i * X_i)/lambda
    ddt_X = zeros(p.N, 1);
    ddt_X(1) = (v.L(2,:).*(X(2,:) - X(1,:)) - v.V(1,:).*v.Y(1,:) + v.V0.*v.Y0...
                + u.Q{1}(t).*X(1,:))./MM(1,:);
    for n = 2:p.N-1
        ddt_X(n) = (v.L(n+1,:)*(X(n+1,:) - X(p.N,:)) - v.V(n,:)*v.Y(n,:)...
                   + v.V(n-1,:)*v.Y(n-1,:) + u.Q{n}(t).*X(n,:))./MM(n,:);
    end
    ddt_X(2) = ddt_X(2) + (u.LF(t).*(u.XF(t) - X(2,:)))./MM(2,:);
    ddt_X(p.N) = (v.LR*(X(end,:) - X(p.N,:)) - v.V(p.N,:)*v.Y(p.N,:)...
                 + v.V(p.N-1,:)*v.Y(p.N-1,:) + u.Q{p.N}(t).*X(p.N,:))./MM(p.N,:);
    ddt_XB = (v.L(1,:).*X(1,:) - v.LB.*X(end-1,:) - v.V0*v.Y0)/10;
    ddt_XD = (v.V(p.N,:) * (v.Y(p.N,:) - X(end,:)))/10;
    dxdt = [ddt_MM; ddt_X; ddt_XB; ddt_XD];

end