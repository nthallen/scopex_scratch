%%
% Overlay ascender temp curves for 220907.1 (Day 1 PM)
%%
% Nav analysis for first Hang Test
runs = { '220906.2', '220907.1', '220907.3','220907.4'};
titles = { 'Day1 AM', 'Day1 PM', 'Day2 AM', 'Day2 PM'};
for runidx = 2 % 1:length(runs)
run = runs{runidx};
runname = titles{runidx};
D1 = load(['RAW/' run '/scopexeng_1.mat']);
T1 = time2d(D1.Tscopexeng_1);
%E = load(['RAW/' run '/scopexeng_2.mat']);
%F = load(['RAW/' run '/scopexeng_10.mat']);
%%
end
%%
Cmd = D1.AscSpeedCmd;
starts = find(T1 < 10685 & [diff(Cmd > 10) > 0; 0]);
ends = find(T1 < 10685 & [0;diff(Cmd > 10) < 0]);
N = length(starts);
figure;
for i=1:N
  V = starts(i):ends(i);
  leg{N+1-i} = sprintf('%d from %.1f C',Cmd(V(2)),D1.AscOutputPulleyT(V(1)));
  plot(T1(V) - T1(V(1)), D1.AscOutputPulleyT(V)-D1.AscOutputPulleyT(V(1)));
  hold('on');
end
hold('off');
legend(leg{N:-1:1},'Location','SouthEast');
title('Temperature Rise at various speeds');
xlabel('Seconds');
ylabel('Degrees C');
