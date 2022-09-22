%%
% Analysis of data runs for feedforward simulations
chdir C:\Data\scopex
%%
T1 = time2d(scopexeng_1.Tscopexeng_1);
T10 = time2d(scopexeng_10.Tscopexeng_10);
T0 = T10(1);
T10 = T10 - T0;
T1 = T1 - T0;
heading = scopexeng_10.heading;
Nav_Status_1 = scopexeng_1.Nav_Status;
Nav_Status = interp1(T1, Nav_Status_1, T10, 'previous');
angvelz = scopexeng_10.angular_velocity_z;
dangvelz = [0;diff(angvelz)];
V = Nav_Status > 1 & abs(dangvelz) > 0.02;
angvelzv = angvelz;
angvelzv(~V) = NaN;
vzdt = [2;diff(T10(V))];
% Now want to locate contiguous values of 0.1clc

% A string begins when there is a change in value (diff ~= 0)
% and the righthand value is 0.1 (or < 0.15)
dvzdt = [0; diff(vzdt)];
starts = find((abs(dvzdt) > 0.05) & (vzdt < 0.15));
% A string ends when there is a change in value
% and the lefthand value was 0.1 (or < 0.15)
dvzdt2 = diff([vzdt; 0]);
ends =  find((abs(dvzdt2) > 0.05) & (vzdt < 0.15));
T10V = T10(V);
runlen = ends-starts+1;

% figure;
% ax = [nsubplot(2,1,1) nsubplot(2,1,2)];
% plot(ax(1),T10(V),vzdt,'.',T10V(starts), vzdt(starts),'*',T10V(ends), vzdt(ends),'*');
% plot(ax(2),T10(V),dvzdt,'.',T10V(starts), dvzdt(starts), '*');
% linkaxes(ax,'x');

% thrust and differential thrust
thrust = scopexeng_1.Nav_Thrust * 40 / 100;
thrusti = interp1(T1,thrust,T10,'previous');
thrust_l = (scopexeng_10.PMC_Left_RPM.^2)/2270;
thrust_r = (scopexeng_10.PMC_Right_RPM.^2)/2270;
dthrust = thrust_l - thrust_r;
%%
figure;
ax = [nsubplot(5,1,1) nsubplot(5,1,2) nsubplot(5,1,3) nsubplot(5,1,4) nsubplot(5,1,5)];
plot(ax(1), T10, angvelz, T10, angvelzv);
%plot(ax(2), T10, dangvelz);
plot(ax(2), T1, thrust, T10, thrust_l, T10, thrust_r);
%plot(ax(3), T10(V), vzdt,'.');
plot(ax(3), T10V(starts), runlen, '.');
plot(ax(4), T10, Nav_Status);
plot(ax(5), T10, dthrust);
linkaxes(ax,'x');
%%
% Things still to do here:
% Extract differential thrust
% For each excursion (positive and negative)record:
%   thrust
%   differential thrust
%   length of accel, hold, decel
%   Total change in heading angle
%     From T2-0.3 to T3+1
%      or one before angular acceleration kicks in at T2
%      to where it flatlines at T3
%     From T3+3 or where reverse angular accelartion kicks in
%      to where it flatlines near T4
%   Starting and Ending angular velocities
%-----------------
% R struct with members that are vectors, including:
%  thrust
%  dthrust
%  Ta, Tb, Ta' as observed
%  dheading
%  angvel0, angvel1
%-----------------
% thrust should be constant through 2-4
% Take max(dthrust) for right turn, min(dthrust) for left turn
% I have already calculated the Ta values. Can I pull out Tb?
% Determine t2, t3, t3a, t4 using Nav_Status and diff(angvelz)
% dheading left is heading(t3)-heading(t2)
% dheading right is heading(t4)-heading(t3a)
% angvel0 = angvelz(t2) angvel1 = angvelz(t3) for left
% angvel0 = angvelz(t3a) angvel1 = angvelz(t4) for right
%-----------------
dStat = [0; diff(Nav_Status)];
Viter = dStat ~= 0 & Nav_Status == 2;
T_iter = T10(Viter) - 1;
n_iter = 2*length(T_iter);

R.thrust = zeros(n_iter,0);
R.dthrust = zeros(n_iter,0);
R.t_accel = zeros(n_iter,0);
R.t_coast = zeros(n_iter,0);
R.t_decel = zeros(n_iter,0);
R.dheading = zeros(n_iter,0);
R.angvel0 = zeros(n_iter,0);
R.angvel1 = zeros(n_iter,0);

for iter = 1:length(T_iter)
  iter_l = 2*iter - 1;
  iter_r = 2*iter;
  si = find(T10V(starts) > T_iter(iter),1);
  t0i = find(T10 == T10V(starts(si)),1) - 2;
  t1i = find(T10 == T10V(ends(si)),1) + 1;
  t2i = find(T10 == T10V(starts(si+1)),1) - 2;
  t3i = find(T10 == T10V(ends(si+1)),1) + 1;
  R.thrust(iter_l:iter_r) = thrusti(t2i);
  R.dthrust(iter_l) = max(dthrust(t0i:t3i));
  R.t_accel(iter_l) = T10(t1i)-T10(t0i);
  R.t_coast(iter_l) = T10(t2i)-T10(t1i);
  R.t_decel(iter_l) = T10(t3i)-T10(t2i);
  R.dheading(iter_l) = heading(t3i)-heading(t0i);
  R.angvel0(iter_l) = angvelz(t0i);
  R.angvel1(iter_l) = angvelz(t3i);
  
  t0i = find(T10 == T10V(starts(si+2)),1) - 2;
  t1i = find(T10 == T10V(ends(si+2)),1) + 1;
  t2i = find(T10 == T10V(starts(si+3)),1) - 2;
  t3i = find(T10 == T10V(ends(si+3)),1) + 1;
  R.dthrust(iter_r) = min(dthrust(t0i:t3i));
  R.t_accel(iter_r) = T10(t1i)-T10(t0i);
  R.t_coast(iter_r) = T10(t2i)-T10(t1i);
  R.t_decel(iter_r) = T10(t3i)-T10(t2i);
  R.dheading(iter_r) = heading(t3i)-heading(t0i);
  R.angvel0(iter_r) = angvelz(t0i);
  R.angvel1(iter_r) = angvelz(t3i);
end
%%
figure;
plot(R.dthrust,R.t_accel,'.',R.dthrust,R.t_coast,'.',R.dthrust,R.t_decel,'.');
ylabel('Seconds');
xlabel('dThrust Newtons');
legend('accel','coast','decel');shg
%%
figure;
thrusts =  unique(R.thrust);
for i = 1:length(thrusts)
  thi = R.thrust == thrusts(i);
  plot(R.dthrust(thi),R.dheading(thi),'.');
  hold on;
end
hold off;
title('dHeading grouped by average thrust');
xlabel('dThrust Newtons');
ylabel('dHeading degrees');
legend(num2str(thrusts'),'Location','NorthWest');
