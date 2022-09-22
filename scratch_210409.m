%%
LRPM = scopexeng_10.PMC_Left_RPM;
RRPM = -scopexeng_10.PMC_Right_RPM;
dRPM = LRPM - RRPM;
Course = scopexeng_1.Course;
Course = Course - (Course>180)*360;
T1 = time2d(scopexeng_1.Tscopexeng_1);
T10 = time2d(scopexeng_10.Tscopexeng_10);
f = figure;
ax = [nsubplot(2,1,1) nsubplot(2,1,2)];
plot(ax(1), T1, Course, ...
  T10, scopexeng_10.Track, ...
  T10, scopexeng_10.heading);
set(ax(1),'xticklabel',[]);
ylabel(ax(1),'Heading');
legend(ax(1),'Course','Track','Heading');
plot(ax(2), T10, LRPM, T10, RRPM, T10, dRPM);
grid;
set(ax(2),'yaxislocation','right');
ylabel(ax(2),'RPM');
legend(ax(2),'Left','Right','diff');
linkaxes(ax,'x');
%%
% Compare my difference in heading to the reported
% angular velocity
heading = scopexeng_10.heading;
dheading = 10*[0; diff(heading)];
avz = scopexeng_10.angular_velocity_z;
f = figure;
ax = [nsubplot(2,1,1) nsubplot(2,1,2)];
plot(ax(1),T10, dheading, T10, avz);
set(ax(1),'xticklabel',[]);
ylabel(ax(1),'dH/dt');
legend(ax(1),'dHeading', 'Reported');
plot(ax(2),T10,heading);
set(ax(2),'yaxislocation','right');
ylabel(ax(2),'Heading');
linkaxes(ax,'x');
%%
% Figure demonstrating that the angular velocity reported by the
% simulator is apparently off by a factor of 2
figure;
plot(T10, avz./dheading);
%%
% Double check by integrating avz from ~57770 to ~57810
% Start with the first non-zero value and stop with the last non-zero
% value.
i0 = find(T10>=57769 & avz ~= 0, 1);
i1 = find(T10>=57800 & avz == 0, 1);
v = i0:i1;
dH = heading(i1)-heading(i0);
intavz = sum(avz(v))/10;
