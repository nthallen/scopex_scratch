%%
% Ascender analysis for first Hang Test
runs = { '220906.2', '220907.1', '220907.3','220907.4'};
titles = { 'Day1 AM', 'Day1 PM', 'Day2 AM', 'Day2 PM'};
for runidx = 1:length(runs)
run = runs{runidx};
runname = titles{runidx};
D = load(['RAW/' run '/scopexeng_1.mat']);
E = load(['RAW/' run '/scopexeng_10.mat']);
%%
T1 = time2d(D.Tscopexeng_1);
T10 = time2d(E.Tscopexeng_10);
%%
N = length(T1);
T1I = 1:N;
nrest = interp1(T1,T1I,T10,'nearest');
GPSheight = zeros(N,1);
for i=T1I
  GPSheight(i) = mean(E.height(find(nrest == i)));
end
dGPSheight = [0; diff(GPSheight)];
%%
% Locate crane movements: GPSheight changing by more than 0.3 m/s while
% mode ~= 2. Only look after first motion
firstmove = find(D.AscMode == 2,1);
i = 0;
crnmvt = [];
direction = [];
ncrnmvts = 0;
threshold = 0.26;
while i < N
  i = find(T1I' > i & abs(dGPSheight) >= threshold & D.AscMode ~= 2,1);
  if ~isempty(i)
    direct = sign(dGPSheight(i));
    if direct > 0
      tdirection = 'up';
    else
      tdirection = 'down';
    end
    j = find(T1I' < i & dGPSheight*direct < 0,1,'last')+1;
    k = find(T1I' > i & dGPSheight*direct < 0,1);
    dh = abs(diff(GPSheight([j k])));
    if dh > 1
      %fprintf(1,'Found crane movement %s from %.0f through %.0f\n', ...
      %  tdirection, T1(j), T1(k));
      ncrnmvts = ncrnmvts+1;
      crnmvt(ncrnmvts,:) = [j k];
      direction(ncrnmvts) = direct;
    end
    i = k;
  end
end
%%
figure;
ax = [nsubplot(3,1,1), nsubplot(3,1,2), nsubplot(3,1,3)];
plot(ax(1),T1,D.AscPosition,T1,GPSheight);
redraw_digital_status(plot(ax(2),T1,D.AscMode,'.'), ...
  {'***','idle','Moving','RecovErr','UnrecErr'});
ylabel(ax(2),'AscMode');
set(ax(2),'YAxisLocation','Right');

plot(ax(3),T1,dGPSheight,'.');
for i = 1:length(direction)
  hold(ax(3),'on');
  mvt = crnmvt(i,:);
  mvtx = mvt(1):mvt(2);
  if direction(i) > 0; pltcode = '.r'; else; pltcode = '.g'; end
  plot(ax(3),T1(mvtx),dGPSheight(mvtx),pltcode);
end
hold(ax(3),'off');
set(ax([1 2]),'XTickLabels',[]);
linkaxes(ax,'x');
title(ax(1),runname);
%%
% Now let's essentially zero the GPSheight after each crane movement
zGPSheight = GPSheight;
i = 1;
mvti = 1;
while i < N
  if mvti <= ncrnmvts
    X = i:crnmvt(mvti,1);
    zGPSheight(X) = GPSheight(X)-GPSheight(X(1))+D.AscPosition(X(1));
    X = crnmvt(mvti,1):crnmvt(mvti,2);
    zGPSheight(X) = D.AscPosition(X(1));
    mvti = mvti+1;
  else
    X = i:N;
    zGPSheight(X) = GPSheight(X)-GPSheight(X(1))+D.AscPosition(X(1));
  end
  i = X(end);
end
%%
figure;
ax = [nsubplot(2,1,1) nsubplot(2,1,2)];
plot(ax(1),T1,D.AscPosition,T1,zGPSheight);
ylabel(ax(1),'AscPosition');
legend(ax(1),'AscPosition','relative GPS');
plot(ax(2),T1,D.AscPosition-zGPSheight);
ylabel(ax(2),'difference');
hold(ax(2),'on');
X = crnmvt(:,2);
h = plot(ax(2),T1(X),D.AscPosition(X)-zGPSheight(X),'.r');
hold(ax(2),'off');
set(h,'MarkerSize',10);
grid(ax(2));
set(ax(2),'YAxisLocation','Right');
legend(ax(2),'diff','crane mvt');
title(ax(1),runname);
linkaxes(ax,'x');
%%
% Calculate drive rates
% Find each drive using AscMode
runstarts = find(diff(D.AscMode==2)>0)+1;
runends = find(diff(D.AscMode==2)<0)+1;
runcmds = D.AscSpeedCmd(runstarts);
runspds = D.AscSpeed(runstarts+1);
rundurs = T1(runends) - T1(runstarts);
runspdsGPS = (GPSheight(runends)-GPSheight(runstarts)) ./ ...
  rundurs;
figure; plot(runcmds, runspds, 'o',runcmds,runspdsGPS,'+');
ylabel('Drive Speed m/s');
xlabel('Commanded Speed %');
legend('Reported','GPS','Location','Southeast');
title(sprintf('%s: Drives Speeds', runname));
grid;
%%
V1 = runcmds == 100;
V2 = runcmds == -100;
figure;
plot(rundurs(V1),runspdsGPS(V1),'+', rundurs(V2),-runspdsGPS(V2),'o');
grid;
ylabel('runspdsGPS');
xlabel('rundurs secs');
legend('Up','Down','Location','Southeast');
title(sprintf('%s: 100%% Drives', runname));
end
