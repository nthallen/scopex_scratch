%%
% scratch_221002.m
% Look at recoil
% Max Min Final heading
% G = [
%   397 NaN 343
%   409 NaN 381
%   293 NaN 312
%   570 NaN 557
%   297 NaN 315
%   NaN NaN NaN
%   376 NaN 393
%   651 597 NaN
%   110 147 NaN
%   1038 978 986
%   1436 1382 1392
%   867 905  900
%   1335 1298 1305
%   927 948 940
%   ];
%%
% scratch_220930.m
% Try adding webbing into model
%
%
%%
% Move ahead to more complex formulation
runidx = 3;
TVs = {[],[],[22560 24926],[]};
Trange = TVs{runidx};
%for prop_delay = 0:10 % in 0.1 sec increments
%
runs = { '220906.2', '220907.1', '220907.3','220907.4'};
titles = { 'Day1 AM', 'Day1 PM', 'Day2 AM', 'Day2 PM'};
run = runs{runidx};
runname = titles{runidx};
D = load(['RAW/' run '/scopexeng_1.mat']);
E = load(['RAW/' run '/scopexeng_2.mat']);
F = load(['RAW/' run '/scopexeng_10.mat']);
T1 = time2d(D.Tscopexeng_1);
T2 = time2d(E.Tscopexeng_2);
T10 = time2d(F.Tscopexeng_10);
TV = TVs{runidx};
if isempty(TV)
  T1V = true(size(T1));
  T2V = true(size(T2));
  V10 = true(size(T10));
  T10Vd = V10;
else
  T1V = T1>=TV(1) & T1 <= TV(2);
  T2V = T2>=TV(1) & T2 <= TV(2);
  V10 = T10>=TV(1) & T10 <= TV(2);
%   I10 = (1:length(V10))';
%   T10Vd = I10 >= find(V10,1,'first')+prop_delay & ...
%     I10 <= find(V10,1,'last')+prop_delay;
  %T10Vd = find(V10) + prop_delay;
  T10Vd = V10;
end
T10V = T10(V10);
LRPM = interp1(T2,E.PMC_Left_RPM,T10(T10Vd),'linear');
RRPM = interp1(T2,E.PMC_Right_RPM,T10(T10Vd),'linear');
LRPM_SP = interp1(T1,D.PMC_Left_RPM_SP,T10(T10Vd),'linear');
RRPM_SP = interp1(T1,D.PMC_Right_RPM_SP,T10(T10Vd),'linear');
dThrust_pct = interp1(T1,D.Nav_dThrust_pct,T10(T10Vd),'linear');
T_acc = interp1(T1,D.Nav_T_acc,T10(T10Vd),'linear')*5;
LThrust = 8e-5 * abs(LRPM).^2.1625;
RThrust = 8e-5 * abs(RRPM).^2.1625;
Thrust = LThrust - RThrust;
Tau_prop = Thrust * (1.24+0.625);
omega = F.angular_velocity_z(V10);
alpha = diff(omega)*10; % to sec^(-1). diff before NaN
alpha = [alpha;0];
sign_omega = sign(omega);
RPMnz = LRPM_SP ~= 0 | RRPM_SP ~= 0;
starts = find(diff(RPMnz) > 0); % in V10
ends = [starts(2:end); length(RPMnz)];
%
heading = F.heading(V10);
% Unwrap heading
dheading = [0; diff(heading)];
dheading(abs(dheading)<200) = 0;
dheading = cumsum(-sign(dheading)*360);
heading_uw = heading + dheading;
%%
ax = nsubplots(2);
plot(ax(1),T10(V10),Thrust);
plot(ax(2),T10(V10),heading_uw);
%%
figure;
for i=1:length(starts)
  % Identify the pulse length
  Vpulse = starts(i):ends(i);
  hdV = heading_uw(Vpulse);
  thV = Thrust(Vpulse);
  if mean(thV) < 0
    hdV = -hdV;
  end
  PkI = find(hdV == max(hdV),1);
  plot(T10V(Vpulse)-T10V(Vpulse(PkI)),hdV-max(hdV));
  hold on
  % Identify the first peak
  % PLot it
end
hold off
%%
N = length(starts);
Pks = [];
PkHts = [];
T_accs = [];
dThPcts = [];
%ax = nsubplots(2);
for i=N:-1:1
  % Identify the pulse length
  Vpulse = starts(i):ends(i);
  T_accs(i) = T_acc(Vpulse(1));
  dThPcts(i) = dThrust_pct(Vpulse(1));
  hdV = heading_uw(Vpulse);
  thV = Thrust(Vpulse);
  if mean(thV) < 0
    hdV = -hdV;
  end
  PkI = find(hdV == max(hdV),1);
  dhdV = fmedianf(diff(hdV),20);
  idx = (1:length(dhdV)-1)';
%   plot(ax(1),idx,dhdV(1:end-1),'.');
%   plot(ax(2),idx,diff(sign(dhdV)),'.');
%   pause;
%   fprintf(1,' %d', i);
  pks = find(idx > PkI-5 & diff(sign(dhdV)) & dhdV(2:end)~=0,4)'+1;
  pkhts = hdV(pks)';
  pks(1,end+1:4) = NaN;
  pkhts(1,end+1:4) = NaN;
  Pks(i,:) = [PkI pks];
  PkHts(i,:) = pkhts;
%   figure;
%   plot(idx,hdV(idx),pks,pkhts,'*');
%   pause;
end
%fprintf(1,'\n');
Vi = find(all(~isnan(Pks')));
PksA = Pks(Vi,2:end);
PkHtsA = PkHts(Vi,:);
%%
PksB = PksA - PksA(:,1)*ones(1,size(PkHtsA,2));
PkHtsB = PkHtsA - PkHtsA(:,1)*ones(1,size(PkHtsA,2));
T_accsA = T_accs(Vi);
dThPctsA = dThPcts(Vi);
GuessX = mean(PksB(:,[3 4]),2);
GuessHt = mean(PkHtsB(:,[3 4]),2);
figure;
plot(PksB',PkHtsB','.-',GuessX,GuessHt,'*');
periods = mean(diff(PksB,1,2),2);
recoil = PkHtsB(:,1)-GuessHt;
%%
figure;
plot(dThPctsA,recoil,'*');