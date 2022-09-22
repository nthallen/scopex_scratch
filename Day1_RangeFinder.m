%% Marco data, Day 1 AM
Heights = [
  % time2d, meters from ground, GPS crane height?
  % Initial crane lift
  85137, 8.76, 8.76; % GPS reported as 54.1 to 63.8 (9.7m)
               % but 63.1 (9m) may be more accurate
  % 23:46:56.989 srvr: tmserio: ascender set Speed -10 pct For 20 sec
  85630, 8.34, 8.76; % GPS barely detectable
  % 23:50:00.252 srvr: tmserio: ascender set Speed 10 pct For 20 sec
  85806, 8.62, 8.76; % GPS barely detectable
  % 23:53:18.297 srvr: tmserio: ascender set Speed -100 pct For 10 sec
  % Transient error observed
  86000, 6.61, 8.76;
  % 23:55:30.578 srvr: tmserio: ascender set Speed 100 pct For 10 sec
  86132, 8.15, 8.76;
  % 24:08:07: Main crane lift
  86887, 38.99, 38.99;
  % 00:15:31.633 srvr: tmserio: ascender set Speed -100 pct For 62 sec
  % Only 16 before errr
  87333, 36.47, 38.99;
  % 00:23:31.326 srvr: tmserio: ascender set Speed -50 pct For 62 sec
  87874, 30.93, 38.99;
  % 00:30:49.288 srvr: tmserio: ascender set Speed -50 pct For 3 min
  88430, 14.26, 38.99;
  % 00:30:49.288 srvr: tmserio: ascender set Speed -50 pct For 3 min
  89088, 1.52, 38.99
];

meanGroundAlt = 54.3; % average of all time before 85035.3
%%
RopeLenRF = Heights(:,3)-Heights(:,2);
AltRF = Heights(:,2) + meanGroundAlt;
ax = nsubplots(2);
plot(ax(1),T10,E.height,Heights(:,1),AltRF,'or');
ylabel(ax(1),'GPS Altitude');
set(ax(1),'XTickLabels',[],'YAxisLocation','Right');
plot(ax(2),T10,E.height_std);
ylabel(ax(2),'Alt std');
%%
