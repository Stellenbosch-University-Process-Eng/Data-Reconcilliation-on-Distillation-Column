%% Examples of DR
% Example
y1 = ones(7,1);
y2 = [2;2;2;2;2;10];
yDR = [y1;y2];

x  = [yL1(end); yL2(end); yL3(end); yL4(end); yLB(end); yLD(end); yLR(end);...
      yV0(end); yV1(end); yV2(end); yV3(end); yV4(end); u.LF(end)]

V = [0.6724; 0.2809; 0.2116; 0.5041; 0.2025; 1.44; 0.5; 0.5; 0.5; 0.5; 0.5; 0.5; 0.5];
I = eye(13);

for i = 1:13
    for j = 1:13
        if I(i,j) ~= 0
            I(i,j) = V(i);
        end    
    end
end
%    L1 L2 L3 L4 LB LD LR V0 V1 V2 V3 V4 LF
A = [+1 +0 +0 +0 -1 +0 +0 -1 +0 +0 +0 +0 +0;... 
     -1 +1 +0 +0 +0 +0 +0 +1 -1 +0 +0 +0 +1;... 
     +0 -1 +1 +0 +0 +0 +0 +0 +1 -1 +0 +0 +0;... 
     +0 +0 -1 +1 +0 +0 +0 +0 +0 +1 -1 +0 +0;... 
     +0 +0 +0 -1 +0 +0 +1 +0 +0 +0 +1 -1 +0;... 
     +0 +0 +0 +0 +0 -1 -1 +0 +0 +0 +0 +1 +0];  
 
x_D  = x - I*A'*inv(A*I*A')*A*x;
x_DR = yDR - inv(I)*A'*inv(A*inv(I)*A')*(A*yDR);