%%
% Nav analysis for first Hang Test
% Define runidx to by 1, 2, 3 or 4 before running
runs = { '220906.2', '220907.1', '220907.3','220907.4'};
titles = { 'Day1 AM', 'Day1 PM', 'Day2 AM', 'Day2 PM'};
run = runs{runidx};
runname = titles{runidx};
D = load(['RAW/' run '/scopexeng_1.mat']);
E = load(['RAW/' run '/scopexeng_2.mat']);
F = load(['RAW/' run '/scopexeng_10.mat']);
%%
T1 = time2d(D.Tscopexeng_1);
T2 = time2d(E.Tscopexeng_2);
T10 = time2d(F.Tscopexeng_10);
TVs = {[],[],[24906 30058],[33536 40436]};
CourseCorr = {[],[],[24905,2;26565,3;27730,1;29825,4], ...
  [33536,0;37027,1;37674,1;38690,-1;40375,1]};
TV = TVs{runidx};
if isempty(TV)
  T1V = true(size(T1));
  T2V = true(size(T2));
  T10V = true(size(T10));
else
  T1V = T1>=TV(1) & T1 <= TV(2);
  T2V = T2>=TV(1) & T2 <= TV(2);
  T10V = T10>=TV(1) & T10 <= TV(2);
end
%%
% Calculate heading error
%   F.heading 10 Hz
%   D.Nav_Course 1 Hz
heading = F.heading;
course = interp1(T1,D.Nav_Course,T10,'nearest');
course(course<0) = course(course<0)+360;

%%
% Unwrap heading
dheading = [0; diff(heading)];
dheading(abs(dheading)<200) = 0;
dheading = cumsum(-sign(dheading)*360);
dcourse = zeros(size(course));
CC = CourseCorr{runidx};
CCX = zeros(size(CC));
for i = 1:size(CC,1)
  CCX(i,1) = find(T10>CC(i,1),1);
  if i > 1
    CCX(i,2) = sum(CC(1:i-1,2)) + CC(i,2)/2 + course(CCX(i,1))/360;
  else
    CCX(i,2) = NaN;
  end
  dcourse(CCX(i,1)) = CC(i,2);
end
dcourse = cumsum(dcourse);
