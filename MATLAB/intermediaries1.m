function v = intermediaries1(t, x, u, p)

    v.V1 = 5 + u.Q1(t);
    v.V2 = v.V1  + u.Q2(t);
    v.V3 = v.V2  + u.Q3(t);
    v.V4 = v.V3  + u.Q4(t);

    v.Y0 = 0.7*x.XB/(0.3*x.XB);
    v.Y1 = 0.7*x.X1/(0.3*x.X1);
    v.Y2 = 0.7*x.X2/(0.3*x.X2);
    v.Y3 = 0.7*x.X3/(0.3*x.X3);
    v.Y4 = 0.7*x.X4/(0.3*x.X4);

end 