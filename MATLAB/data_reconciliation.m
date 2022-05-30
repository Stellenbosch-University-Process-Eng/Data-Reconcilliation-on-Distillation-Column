%% Function that runs the DR
% Exam
y1 = ones(7,2);
y2 = [2 2;2 2;2 2;2 2;2 2;10 10];
yDR = [y1;y2];

xDR  = [yL1(end) yL1(end-1); yL2(end) yL2(end-1); yL3(end) yL3(end-1); yL4(end) yL4(end-1);...
      yLB(end) yLB(end-1); yLD(end) yLD(end-1); yLR(end) yLR(end-1);...
      yV0(end) yV0(end-1); yV1(end) yV1(end-1); yV2(end) yV2(end-1); yV3(end) yV3(end-1);...
      yV4(end) yV4(end-1); u.LF(end) u.LF(end-1)];

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
 
x_D  = xDR - I*A'*inv(A*I*A')*A*xDR;
x_DR = yDR - inv(I)*A'*inv(A*inv(I)*A')*(A*yDR);