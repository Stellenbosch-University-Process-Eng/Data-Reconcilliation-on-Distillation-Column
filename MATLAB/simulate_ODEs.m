function dxdt = simulate_ODEs(t, x, u, p)
% This fucntion simulates the molar holdup ODEs
        
    xS = vector_2_structure(x, p.fieldsM);
    v  = intermediaries(t, xS, u, p);

    ddt.MM1 = v.L2 - v.L1 - u.Q1(t);
    ddt.MM2 = v.L3 - v.L2 + u.LF(t) - u.Q2(t);
    ddt.MM3 = v.L4 - v.L3 - u.Q3(t);
    ddt.MM4 = u.LR(t) - v.L4 - u.Q4(t);

    dxdt = structure_2_vector(ddt, p.fieldsM);

end