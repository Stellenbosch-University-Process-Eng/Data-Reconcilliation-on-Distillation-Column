function v = intermediaries(t, x, u, p)

    v.V0 = u.Freb(t);
    v.L1 = sqrt(x.MM1);
    v.L2 = sqrt(x.MM2);
    v.L3 = sqrt(x.MM3);
    v.L4 = sqrt(x.MM4);
    v.LB = v.L1 - v.V0;
    
end 