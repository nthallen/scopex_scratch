%% scratch 220922
% Analyzing thrust, moment of intertia and swivel friction
%
% We are most likely interested in
% data from the morning of Day 2, when we were doing open loop asymmetric
% thrust testing.
runidx = 3; load_course_data
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
best_delay = zeros(length(starts),1);
for i = 1:length(starts)
  V = starts(i):ends(i);
  if any(LRPM_SP(V) > 0)
    Torque = LThrust*(1.24+0.625);
    AV = F.angular_velocity_z(V);
  else
    Torque = RThrust*(1.24+0.625);
    AV = -F.angular_velocity_z(V);
  end
  AV = AV - AV(1);

  if 0
    ax = nsubplots(3);
    plot(ax(1),T10(V),Torque(V)); ylabel(ax(1),'Torque');
    plot(ax(2),T10(V),cumsum(Torque(V))); ylabel(ax(2),'\int Torque');
    plot(ax(3),T10(V),AV); ylabel(ax(3),'Ang vel');
    
    set(ax(1:end-1),'XTickLabels',[]);
    set(ax(2:2:end),'YAxisLocation','Right');
    linkaxes(ax,'x');
    title(ax(1),sprintf('%s: pulse %d', runname, i));
  end
  %%
  % Pick the best delay
  ITorque_limit = 18.65;
  Ndelay = 20;
  delay_fits = zeros(Ndelay,2);
  delay_stds = zeros(Ndelay,1);
  for delay = 1:Ndelay
    ITq = cumsum(Torque(V+delay))/10;
    PVV = ITq < ITorque_limit; % arbitrary limit where linearity seems to end
    delay_fits(delay,:) = polyfit(ITq(PVV),AV(PVV),1);
    fitx = ITq(PVV);
    fity = polyval(delay_fits(delay,:),fitx);
    delay_stds(delay) = std(AV(PVV)-fity);
  end
  best_delay(i) = find(delay_stds == min(delay_stds,1);
  fits(i,:) = delay_fits(best_delay(i),:);
  figure;
  plot(1:Ndelay, delay_stds,'*');
  title(sprintf('%s: Pulse %d Delay stds', runname, i));
  xlabel('Delay samples');
  %%
  % Try adjusting delay in PMC RPM data by plotting the integral of Torque vs
  % angular velocity. ITh is now integral of torque
  ITq = cumsum(Torque(V+best_delay(i)))/10;
  % PVV = ITq < ITorque_limit; % arbitrary limit where linearity seems to end
  % fits(i,:) = polyfit(ITq(PVV),AV(PVV),1);
  fitx = [0 100];
  fity = polyval(fits(i,:),fitx);

  if 1
    figure;
    plot( ...
      ITq,AV,'.', ...
      fitx,fity);
    xlabel('\int Torque Nms');
    ylabel('Ang Vel deg/s');
    %xlim([0 20]); ylim([-1 4]);
    title(sprintf('%s: pulse %d', runname, i));
  end
%   ax = nsubplots(2);
%   plot(ax(1),T10(V),cumsum(Torque(V+14)));
%   plot(ax(2),T10(V),AV);
%   title(ax(1),sprintf('%s: pulse %d', runname, i));
end
%%
ax = nsubplots(3);
plot(ax(1),T10(starts), fits(:,1),'*');
ylabel(ax(1),'Slope');
plot(ax(2),T1,D.Nav_T_acc);
ylabel(ax(2),'T_{acc}');
plot(ax(3),T1,D.Nav_dThrust_pct,T10,LThrust*100/40,T10,RThrust*100/40);
ylabel(ax(3),'dThrust %');

set(ax(1:end-1),'XTickLabels',[]);
set(ax(2:2:end),'YAxisLocation','Right');
linkaxes(ax,'x');
title(ax(1),runname);
%%
OK = [1 2 4 5 6 8:14];
nOK = [3 7];
mean_slope = mean(fits(OK,1));
std_slope = std(fits(OK,1));
figure;
plot(OK,fits(OK,1),'*', nOK, fits(nOK,1),'*', [0 15], mean_slope*[1 1]);
ylabel('Slope');
title(sprintf('%s: Limite = %.2f Slopes %.3f +/- %.5f', runname, ...
  ITorque_limit, mean_slope, std_slope));
grid on;

