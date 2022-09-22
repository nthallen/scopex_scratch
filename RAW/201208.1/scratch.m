%%
B = load('B3MBraw.mat');
T = time2d(B.TB3MBraw);
L1V = B.B3MB_100V1_Load1_V;
L2V = B.B3MB_100V1_Load2_V;
L3V = B.B3MB_100V1_Load3_V;
L4V = B.B3MB_100V1_Load4_V;
L1I = B.B3MB_100V1_Load1_I;
L2I = B.B3MB_100V1_Load2_I;
L3I = B.B3MB_100V1_Load3_I;
L4I = B.B3MB_100V1_Load4_I;
figure;
plot(T,L1I,'.',T,L2I,'.',T,L3I,'.',T,L4I,'.');
title('Raw Load Currents');
legend('1','2','3','4');
