function dxdt = simulate_ODEs1(t, x, vM, u, p)
% This fucntion simulates the concentration ODEs
% vM is the intermediary structure calculate by solving the first ODEs.
        
    xS = vector_2_structure(x, p.fieldsX);
    v  = intermediaries1(t, xS, u, p);

    ddt.X1 = (vM.L2)*(v.X2) - (vM.L1)*(v.X1) - (v.V1)*(v.Y1) + (vM.V0)*(v.Y0);
    ddt.X2 = (vM.L3)*(v.X3) + (u.LF(t))*(u.XF(t)) - (vM.L2)*(v.X2) - (v.V2)*(v.Y2) + (v.V1)*(v.Y1);
    ddt.X3 = (vM.L4)*(v.X4) - (vM.L3)*(v.X3) - (v.V3)*(v.Y3) + (v.V2)*(v.Y2);
    ddt.X4 = (u.LR(t))*(v.XD*2) - (vM.L4)*(v.X4) - (v.V4)*(v.Y4) + (v.V3)*(v.Y3);
    ddt.XB = (vM.L1)*(v.X1) - (vM.LB)*(v.XB) - (vM.V0)*(v.Y0);
    ddt.XD = v.V4*(v.Y4 - v.XD);

    dxdt = structure_2_vector(ddt, p.fields);

end