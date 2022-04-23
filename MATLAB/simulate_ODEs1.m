function dxdt = simulate_ODEs1(t, x, vM, u, p)
        
    xS = vector_2_structure(x, p.fieldsX);
    v  = intermediaries1(t, xS, u, p);

    ddt.XD = v.V4*(0.9 - v.XD);
    ddt.XB = vM.L1 - vM.LB*v.XB - v.V0*v.Y0;


    dxdt = structure_2_vector(ddt, p.fields);

end