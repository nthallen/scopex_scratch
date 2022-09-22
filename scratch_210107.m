%%
T1 = time2d(scopexeng_1.Tscopexeng_1);
SysTDrift = scopexeng_1.SysTDrift;
T10 = time2d(scopexeng_10.Tscopexeng_10);
nav_drift = scopexeng_10.nav_drift;
SysTDrift10 =  interp1(T1,SysTDrift,T10,'linear','extrap');
%%
figure;
plot(T10,SysTDrift10,'.',T10,nav_drift,'.');
%%
figure;
plot(T10,SysTDrift10-nav_drift,'.');

%%
T10 = time2d(scopexeng_10.Tscopexeng_10);
n_reports = scopexeng_10.SD_n_reports;
figure;
plot(T10, movsum(n_reports,10),'.', T10, movsum(n_reports,20)/2,'.');
