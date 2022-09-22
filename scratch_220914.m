%% scratch_220914.m
% Debugging Nav. Run scratch_220912.m first to load data
LThrust = 8e-5 * abs(E.PMC_Left_RPM).^2.1625;
RThrust = 8e-5 * abs(E.PMC_Right_RPM).^2.1625;
dThrust = LThrust-RThrust;
ax = nsubplots(2);
plot(ax(1),T10,course+dcourse*360,T10,heading+dheading);
set(ax(1),'XTickLabels',[],'YAxisLocation','Right');
ylabel(ax(1), 'Heading');
plot(ax(2),T2,dThrust);
ylabel(ax(2),'dThrust');
linkaxes(ax,'x');

%%
% Run scratch_220912.m for runidx 3 first to load data
% Also run scratch_220911.m for runidx3 to get dGPSheight
% Impulse Analysis
ax = nsubplots(4);
plot(ax(1),T10,heading+dheading);
ylabel(ax(1),'Heading');
grid(ax(1),'on');
title(ax(1),runname);

redraw_digital_status(plot(ax(2),T1(T1V),D.Nav_Status(T1V)), ...
  { 'Idle', 'PID', 'Fail', 'FF\_Init', 'FF\_Pause', ...
             'FF\_Done', 'Port1', 'Stbd1', 'Port2', 'Stbd2' });
set(ax(2),'YAxisLocation','Right','XTickLabels',[]);
ylabel(ax(2),'Status')

LThrust = 8e-5 * (abs(E.PMC_Left_RPM).^2.1625);
RThrust = 8e-5 * (abs(E.PMC_Right_RPM).^2.1625);
dThrust = 100*(LThrust-RThrust)/40;
plot(ax(3),T1,D.Nav_Thrust_pct,T1,D.Nav_dThrust_pct,T2,dThrust);
ylabel(ax(3),'Thrust %');

plot(ax(4),T10,F.angular_velocity_z);
ylabel(ax(4),'\omega');

set(ax(1:end-1),'XTickLabels',[]);
set(ax(2:2:end),'YAxisLocation','Right');
linkaxes(ax,'x');

%%
RPMnz = D.PMC_Left_RPM_SP ~= 0 | D.PMC_Right_RPM_SP ~= 0;
starts = find(diff(T1 < 24894 & RPMnz) > 0);
ends = [starts(2:end); find(T1<24894,1,'last')];
V1 = D.Nav_dThrust_pct > 0;
T1V = T1(V1);
ax = nsubplots(2);
plot(ax(1),T1V,D.PMC_Left_RPM_SP(V1),T1V,D.PMC_Right_RPM_SP(V1), ...
    T1(starts),D.PMC_Left_RPM_SP(starts),'*r', ...
    T1(ends),D.PMC_Left_RPM_SP(ends),'*b');
V10 = T10 >= T1V(1) & T10 <= T1V(end);
plot(ax(2),T10(V10),F.height(V10));

set(ax(1:end-1),'XTickLabels',[]);
set(ax(2:2:end),'YAxisLocation','Right');
linkaxes(ax,'x');
%%
Tstarts = T1(starts);
Tends = T1(ends);
%%
heading_uw = heading+dheading;
dThrusts = zeros(length(starts),1);
RopeLens = zeros(length(starts),1);
TurnDegs = zeros(length(starts),1);
Overshoot = zeros(length(starts),1);
ax = zeros(2,1);
f2 = figure;
ax(2) = gca;
f1 = figure;
ax(1) = gca;
for i=length(starts):-1:1
  Vpulse = T10 >= Tstarts(i) & T10 <= Tends(i);
  T10V = T10(Vpulse);
  hdV = heading_uw(Vpulse);
  VP1 = T1 >= Tstarts(i) & T1 <= Tends(i);
  dThrusts(i) = max(abs(D.Nav_dThrust_pct(VP1 & RPMnz)));
  RopeLens(i) = max(abs(zGPSheight(VP1)));
  TurnDegs(i) = abs(hdV(end)-hdV(1));
  Overshoot(i) = max(abs(hdV-hdV(1))) - TurnDegs(i);

  h(i) = plot(ax(1),T10V-T10V(1),abs(hdV-hdV(1)));
  hold(ax(1), 'on');
  scatter(ax(2),F.east_m(Vpulse),F.north_m(Vpulse),[],T10V);
  drawnow; axes(ax(2));
  pause;
end
hold(ax(1), 'off');
mp = colormap(ax(1));
CL = [min(dThrusts) max(dThrusts)];
Ci = interp1(CL,[1 size(mp,1)],dThrusts);
clrs = interp1(1:size(mp,1),mp,Ci);
for i=1:length(h)
  h(i).Color = clrs(i,:);
end
xlabel(ax(1),'Seconds');
ylabel(ax(1),'Heading deg');
ax1.CLim = CL;
H1 = colorbar(ax(1));
H1.Label.String = 'dThrust';

figure;
scatter(dThrusts,TurnDegs,[],RopeLens);
xlabel('dThrust');
ylabel('Change in Heading deg');
H2 = colorbar;
H2.Label.String = 'Rope Length';

figure;
scatter(1:length(Overshoot),Overshoot,[],clrs);
ylabel('Overshoot deg');
xlabel('Impulse Index');
ax = gca;
ax.CLim = CL;
H3 = colorbar;
H3.Label.String = 'dThrust';
