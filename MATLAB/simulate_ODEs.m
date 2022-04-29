function dxdt = simulate_ODEs(t, x, u, p)
% This fucntion simulates the molar holdup ODEs
        
    MM = x(1:p.N);
    
    v  = intermediaries(t, MM, u, p);
    
    ddt_MM = zeros(p.N, 1);
    for n = 1:p.N-1
        ddt_MM(n) = v.L(n+1) - v.L(n) - u.Q{n}(t);
    end

    ddt_MM(p.N) = u.LR(t) - v.L(p.N) - u.Q{p.N}(t);

    dxdt = ddt_MM;

end