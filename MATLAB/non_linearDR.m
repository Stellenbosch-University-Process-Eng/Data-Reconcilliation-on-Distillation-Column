%% Non-linear Data Reconciliation

f = @(x,y) x.*exp(-x.^2-y.^2)+(x.^2+y.^2)/20;

Aeq = [3 1; 1 -1];
beq = [5; 1];

A = [];
b = [];

sol = fmincon(f,[0 -0.5],A,b,Aeq,beq)

