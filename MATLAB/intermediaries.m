function v = intermediaries(t, x, u, p)
% This fucntion calcuates the intermediaries for the molar holdup ODEs

% Define dependent variables
    MM = x(1:p.N,:);             % mol/min, Molar holdup
    X  = x(p.N+1:end,:);         % ~, Liquid mole fraction
    
% Calculate Vapour molar flowrates
    v.V0 = u.Freb(t);                          % mol/min, Vapour molar flowrate - V0
    v.V(1,:) = v.V0 + u.Q{1}(t);               % mol/min, Vapour molar flowrate - V1
    for n = 2:p.N
        v.V(n,:) = v.V(n-1,:) + u.Q{n}(t);     % mol/min, Vapour molar flowrate - V2:V(p.N)
    end 
    
% Calculate Liquid molar flowrates
    for n = 1:p.N
        v.L(n,:) = (1e-3)*sqrt(MM(n)).*ones(1,length(v.V0));           % mol/min, Liquid molar flowrate - L1:L4
    end
    v.LB = v.L(1,:) - v.V(1,:);                % mol/min, Liquid molar flowrate - LB 
    v.LR = v.V(p.N,:)./(1 + u.R(t));           % mol/min, Liquid molar flowrate - LR
    v.LD = v.LR./u.R(t);                       % mol/min, Liquid molar flowrate - LD

% Calculate Vapour molar flowrates
    v.Y0(1,:) = (p.alpha*X(p.N+1,:))./(1 + (1-p.alpha)*X(p.N+1,:));    % ~, Vapour molar fraction - Y0  
    for n = 1:p.N
        v.Y(n,:) = (p.alpha*X(n,:))./(1 + (1-p.alpha)*X(n,:));         % ~, Vapour molar fraction - Y1:Y4
    end
% Calculate Condenser duty
    v.Qcon(1,:) = v.V(p.N,:);                  % kJ/mol, Condenser heat transfer duty

end 
