%%
% Move ahead to more complex formulation
runidx = 3;
TVs = {[],[],[22574 24808],[]};
Trange = TVs{runidx};
for prop_delay = 0:10 % in 0.1 sec increments
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
  T10V = true(size(T10));
  T10Vd = T10V;
else
  T1V = T1>=TV(1) & T1 <= TV(2);
  T2V = T2>=TV(1) & T2 <= TV(2);
  T10V = T10>=TV(1) & T10 <= TV(2);
  I10 = (1:length(T10V))';
  T10Vd = I10 >= find(T10V,1,'first')+prop_delay & ...
    I10 <= find(T10V,1,'last')+prop_delay;
end
assert(sum(T10V) == sum(T10Vd));
LRPM = interp1(T2,E.PMC_Left_RPM,T10(T10Vd),'linear');
RRPM = interp1(T2,E.PMC_Right_RPM,T10(T10Vd),'linear');
LThrust = 8e-5 * abs(LRPM).^2.1625;
RThrust = 8e-5 * abs(RRPM).^2.1625;
Thrust = LThrust - RThrust;
Tau_prop = Thrust * (1.24+0.625);
omega = F.angular_velocity_z(T10V);
sign_omega = sign(omega);
alpha = diff(omega)*10; % to sec^(-1)
alpha = ([alpha;0] + [0;alpha])/2;
M = [alpha omega sign_omega];
%%
C = M\Tau_prop;
I = C(1);
C_drag = C(2);
C_fric = C(3);
%%
ax = nsubplots(5);
plot(ax(1),T10(T10V),Tau_prop);
ylabel(ax(1),'\tau_{prop}');

plot(ax(2),T10(T10V),-C_drag*omega);
ylabel(ax(2),'\tau_{drag}');

plot(ax(3),T10(T10V),-C_fric*sign_omega);
ylabel(ax(3),'\tau_{fric}');

plot(ax(4),T10(T10V),I*alpha);
ylabel(ax(4),'\alpha');

plot(ax(5),T10(T10V),I*alpha+C_fric*sign_omega+C_drag*omega-Tau_prop);
ylabel(ax(5),'residual');

set(ax(1:end-1),'XTickLabels',[]);
set(ax(2:2:end),'YAxisLocation','Right');
linkaxes(ax,'x');
title(ax(1),sprintf('%s: prop\\_delay %.0f',runname, prop_delay));
ax(1).Parent.WindowState = 'maximized';

fprintf(1,'I = %.1f C_drag = %f C_fric = %f\n', I, C_drag, C_fric);
end
ax = findobj('type','axes');

