%%
T1 = time2d(chgeng_1.Tchgeng_1);
figure;
plot(T1, chgeng_1.B3MB_100V1_Batt1_V, ...
  T1, chgeng_1.B3MB_100V2_Batt1_V, ...
  T1, chgeng_1.B3MB_100V3_Batt1_V, ...
  T1, chgeng_1.B3MB_100V4_Batt1_V, ...
  T1, chgeng_1.B3MB_100V1_Bus_V, ...
  T1, chgeng_1.B3MB_100V2_Bus_V, ...
  T1, chgeng_1.B3MB_100V3_Bus_V, ...
  T1, chgeng_1.B3MB_100V4_Bus_V);
%%
report_cutout_time(T1,chgeng_1,'B3MB_100V1_Batt1_V');
report_cutout_time(T1,chgeng_1,'B3MB_100V2_Batt1_V');
report_cutout_time(T1,chgeng_1,'B3MB_100V3_Batt1_V');
report_cutout_time(T1,chgeng_1,'B3MB_100V4_Batt1_V');
report_cutout_time(T1,chgeng_1,'B3MB_100V1_Bus_V');
%%
function report_cutout_time(T,A,name)
  Ti = find(A.(name) < 15, 1);
  Vi = max(1,Ti-2);
  V = A.(name);
  [H,M,S] = time2hms(T(Ti));
  D = floor(H/24);
  fprintf(1,'%s: %.2fV %d days %02d:%02d:%02d UTC\n', name, ...
    V(Vi), D, H-24*D, M, floor(S));
end
