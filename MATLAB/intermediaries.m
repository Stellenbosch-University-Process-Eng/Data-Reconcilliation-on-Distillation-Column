function v = intermediaries(t, x, u, p)
% This fucntion calcuates the intermediaries for the molar holdup ODEs
    MM = x(1:p.N);

    v.V0 = u.Freb(t);
    for n = 1:p.N
        v.L(n) = sqrt(MM(n));
    end
    v.LB = v.L(1) - v.V0;
    
end 