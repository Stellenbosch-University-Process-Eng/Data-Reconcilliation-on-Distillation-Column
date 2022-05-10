function v = intermediaries(t, x, u, p)
% This fucntion calcuates the intermediaries for the molar holdup ODEs

% Define the dependent variable
    MM = x(1:p.N+2);                % mol/min, Molar holdup
  
% Calculate Vapour molar flowrates
    v.V(1) = u.Freb(t)/p.yy;                    % mol/min, Vapour molar flowrate - V0
    for n = 2:p.N
        v.V(n) = v.V(n-1) + u.Q{n}(t)/p.yy;     % mol/min, Vapour molar flowrate - V1:V4
    end 

% Calculate Liquid molar flowrates
    for n = 1:p.N
        v.L(n) = sqrt(MM(n));       % mol/min, Liquid molar flowrate - L1:L4
    end
    v.LB = v.L(1) - v.V(1);         % mol/min, Liquid molar flowrate - LB 
    v.LR = v.V(4)./(1 + u.R(t));    % mol/min, Liquid molar flowrate - LR
    v.LD = v.LR/u.R(t);             % mol/min, Liquid molar flowrate - LD

% Calculate Condenser duty
    v.Qcon = p.yy*v.V(4);           % kJ/mol, Condenser heat transfer duty

end 