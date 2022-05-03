function v = intermediaries(t, x, u, p)
% This fucntion calcuates the intermediaries for the molar holdup ODEs
    MM = x(1:p.N);

    v.V0 = u.Freb(t);
    v.V1 = v.V0 + u.Q{1}(t);
    v.V2 = v.V1 + u.Q{2}(t);
    v.V3 = v.V2 + u.Q{3}(t);
    v.V4 = v.V3 + u.Q{4}(t);

    for n = 1:p.N
        v.L(n) = sqrt(MM(n));
    end
    v.LB = v.L(1) - v.V0;
    v.LR = v.V4./(1 + u.R(t));
    v.LD = v.LR/u.R(t);
    
end 