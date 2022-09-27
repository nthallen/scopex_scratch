%% scratch 220922
% Analyzing thrust, moment of intertia and swivel friction
% Run scratch_220912.m first to load data.
%
% We are most likely interested in
% data from the morning of Day 2, when we were doing open loop asymmetric
% thrust testing.
LRPM = interp1(T2,E.PMC_Left_RPM,T10,'linear');
RRPM = interp1(T2,E.PMC_Right_RPM,T10,'linear');
LRPM_SP = interp1(T1,D.PMC_Left_RPM_SP,T10,'linear','extrap');
RRPM_SP = interp1(T1,D.PMC_Right_RPM_SP,T10,'linear','extrap');
LThrust = 8e-5 * abs(LRPM).^2.1625;
LThrust_SP = 8e-5 * abs(D.PMC_Left_RPM_SP).^2.1625;
RThrust = 8e-5 * abs(RRPM).^2.1625;
RThrust_SP = 8e-5 * abs(D.PMC_Right_RPM_SP).^2.1625;
dThrust = LThrust-RThrust;
angacc = [0;diff(F.angular_velocity_z)];
%%
ax = nsubplots(3);
plot(ax(1),T1,LThrust_SP,T10,LThrust);
ylabel(ax(1),'Left Thrust');
plot(ax(2),T1,RThrust_SP,T10,RThrust);
ylabel(ax(2),'Right Thrust');
plot(ax(3),T10,F.angular_velocity_z);
ylabel(ax(3),'Angular Vel deg/s');

set(ax(1:end-1),'XTickLabels',[]);
set(ax(2:2:end),'YAxisLocation','Right');
linkaxes(ax,'x');
title(ax(1),runname);
%%
RPMnz = LRPM_SP ~= 0 | RRPM_SP ~= 0;
starts = find(diff(T10 < 24894 & RPMnz) > 0)-5;
ends = find(diff(T10 < 24894 & RPMnz) < 0);
%%
ax = nsubplots(2);
plot(ax(1),T10,LThrust);
plot(ax(2),T10,angacc);
grid(ax(2),'on');

set(ax(1:end-1),'XTickLabels',[]);
set(ax(2:2:end),'YAxisLocation','Right');
linkaxes(ax,'x');
title(ax(1),runname);
%%
fits = zeros(length(starts),2);
for i = 1:length(starts)
  V = starts(i):ends(i);
  if any(LRPM_SP(V) > 0)
    Thrust = LThrust;
    AV = F.angular_velocity_z(V);
  else
    Thrust = RThrust;
    AV = -F.angular_velocity_z(V);
  end
  AV = AV - AV(1);

  if 0
    ax = nsubplots(3);
    plot(ax(1),T10(V),Thrust(V)); ylabel(ax(1),'Thrust');
    plot(ax(2),T10(V),cumsum(Thrust(V))); ylabel(ax(2),'\int Thrust');
    plot(ax(3),T10(V),AV); ylabel(ax(3),'Ang vel');
    
    set(ax(1:end-1),'XTickLabels',[]);
    set(ax(2:2:end),'YAxisLocation','Right');
    linkaxes(ax,'x');
    title(ax(1),sprintf('%s: pulse %d', runname, i));
  end
  %%
  % Try adjusting delay in PMC RPM data by plotting the integral of thrust vs
  % angular velocity
  ITh = cumsum(Thrust(V+13));
  PVV = ITh<100;
  fits(i,:) = polyfit(ITh(PVV),AV(PVV),1);
  fitx = [0 100];
  fity = polyval(fits(i,:),fitx);

  figure;
  plot( ...
    cumsum(Thrust(V+12)),AV,'.', ...
    cumsum(Thrust(V+13)),AV,'.', ...
    cumsum(Thrust(V+14)),AV,'.',fitx,fity);
  xlabel('\int Thrust Ns');
  ylabel('Ang Vel deg/s');
  xlim([0 100]); ylim([-1 4]);
  title(sprintf('%s: pulse %d', runname, i));
%   ax = nsubplots(2);
%   plot(ax(1),T10(V),cumsum(Thrust(V+14)));
%   plot(ax(2),T10(V),AV);
%   title(ax(1),sprintf('%s: pulse %d', runname, i));
end
%%
ax = nsubplots(3);
plot(ax(1),T10(starts), fits(:,1),'*');
plot(ax(2),T1,D.Nav_T_acc);
plot(ax(3),T1,D.Nav_dThrust_pct);

set(ax(1:end-1),'XTickLabels',[]);
set(ax(2:2:end),'YAxisLocation','Right');
linkaxes(ax,'x');
title(ax(1),runname);
