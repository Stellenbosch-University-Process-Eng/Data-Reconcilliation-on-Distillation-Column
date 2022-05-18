function v = intermediaries(t, x, u, p)
% This fucntion calcuates the intermediaries for the molar holdup ODEs

% Define the dependent variable
    MM = x(1:(p.N*2)+2);
    
% Calculate Vapour molar flowrates
    v.V0 = u.Freb(t);                    % mol/min, Vapour molar flowrate - V0
    v.V(1,:) = v.V0 + u.Q{1}(t);
    for n = 2:p.N
        v.V(n,:) = v.V(n-1) + u.Q{n}(t);     % mol/min, Vapour molar flowrate - V1:V4
    end 

% Calculate Liquid molar flowrates
    for n = 1:p.N
        v.L(n,:) = sqrt(MM(n));       % mol/min, Liquid molar flowrate - L1:L4
    end
    v.LB = v.L(1,:) - v.V(1,:);         % mol/min, Liquid molar flowrate - LB 
    v.LR = v.V(p.N,:)./(1 + u.R(t));    % mol/min, Liquid molar flowrate - LR
    v.LD = v.LR./u.R(t);             % mol/min, Liquid molar flowrate - LD

% Calculate Vapour molar flowrates
    v.Y0 = (p.alpha*MM(p.N*2+1))./(1 + (1-p.alpha)*MM(p.N*2+1));
    for n = 1:p.N
        v.Y(n,:) = (p.alpha*MM(n+p.N))./(1 + (1-p.alpha)*MM(n+p.N));
    end
% Calculate Condenser duty
    v.Qcon = v.V(p.N,:);           % kJ/mol, Condenser heat transfer duty

end 