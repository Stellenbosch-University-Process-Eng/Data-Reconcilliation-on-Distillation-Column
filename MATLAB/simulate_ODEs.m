function dxdt = simulate_ODEs(t, x, u, p)
% This fucntion simulates the molar holdup ODEs
% Testing new branch
% Define dependent variables   
    MM = x(1:10);

% Caculates intermediaries
    v  = intermediaries(t, MM, u, p);  
    
% Calculate Molar Holup derivatives 
    ddt_MM = zeros(p.N, 1);
    for n = 1:p.N-1
        ddt_MM(n) = v.L(n+1) - v.L(n) - u.Q{n}(t);     % mol/min, Molar holdup - MM1:MM3
    end
    ddt_MM(2) = ddt_MM(2) + u.LF(t);                % mol/min, Added feed flowrate to MM2
    ddt_MM(p.N) = v.LR - v.L(p.N) - u.Q{p.N}(t);   % mol/min, Molar holdup - MM4

% Calculate Liquid fracion derivatives
    ddt_X = zeros(p.N, 1);
    ddt_X(1) = v.L(2).*(MM(6)-1) + v.L(1).*(1-MM(5)) - v.V(1).*v.Y(1) + v.V0.*v.Y0 + u.Q{n}(t).*MM(5)
    for n = 2:p.N
        ddt_X(n) = v.L(n+1+4)*(MM(n+1+4)-1) + v.L(n)*(1-MM(n+4)) - v.V(n)*v.Y(n) + v.V(n-1)*v.Y(n-1) + u.Q{n}*MM(n+4);
    end
    ddt_XB = v.L(1)*MM(5) - v.LB*MM(9) - v.V0*v.Y0;
    ddt_XD = v.V(p.N) * (v.Y(p.N) - MM(10));
    dxdt = [ddt_MM; ddt_X; ddt_XB; ddt_XD];

end