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

%%
% Ascender V & I vs B3MB readings
B3MBV = [ D1.AscPri1_V D1.AscPri2_V  D1.AscSec1_V  D1.AscSec2_V];
B3MBI = [ D1.AscPri1_I  D1.AscPri2_I  D1.AscSec1_I  D1.AscSec2_I];
B3MBPwr = B3MBV .*B3MBI;
B3MBTpwr = sum(B3MBPwr,2);
%%
ax = nsubplots(2);
plot(ax(1),T1, B3MBV);
ylabel(ax(1),'Voltage');
legend(ax(1),'Pri1','Pri2','Sec1','Sec2');
plot(ax(2),T1,B3MBI);
ylabel(ax(2),'Current');
legend(ax(2),'Pri1','Pri2','Sec1','Sec2');
    
set(ax(1:end-1),'XTickLabels',[]);
set(ax(2:2:end),'YAxisLocation','Right');
linkaxes(ax,'x');
title(ax(1),sprintf('%s: B3MB Ascender Power', runname));
%%
figure;
plot(T1,B3MBTpwr,T1,D1.AscHoistV .* D1.AscHoistI);
legend('B3MB','Ascender');
