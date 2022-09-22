%%
S = 1.5; % m Length of the side of the payload cube
TA = 1.5; % m Length of the torque arm
M = 590.0; % Kg Mass of Payload cube
I = M*S.^2/6;
stepSize = 0.1;
Th0 = 10; % Nominal Newtons of thrust per engine
dTha = 15; % Newtons of differential thrust
intro = 3;
Ta = 2;
Tb = 5.5;
dT = [intro Ta Tb Ta intro];
T0 = -intro;
dThSP = dTha * [0 1 0 -1  0 0];
Tk = T0 + [ 0 cumsum(dT) ];
T = min(Tk):stepSize:max(Tk);
dThSPi = interp1(Tk,dThSP,T,'previous');

[mdThSPi,MdThSPi] = bounds(dThSPi);
RdThSPi = range(dThSPi);

lmarg = 0.05*[-1,1];
verb = false;
if verb; cla; plot(Tk,dThSP,'*',T,dThSPi); shg; end

%%
Th_l = Th0 + dThSP/2;
Th_r = Th0 - dThSP/2;
if verb; cla; plot(Tk,Th_l,Tk,Th_r); shg; end
%%
RPM_l = sqrt(Th_l * 2270);
RPM_r = sqrt(Th_r * 2270);

Ti = 1:length(T);
RPM_li = zeros(size(T));
RPM_ri = zeros(size(T));
Ii = 1;
RPM_li(Ii) = RPM_l(1);
RPM_ri(Ii) = RPM_r(1);
% The following loop fills in from T(Ii) to T(SegEndi)
for SPi = 2:length(Tk)
  SegEndi = interp1(T, Ti, Tk(SPi), 'previous');
  RPM_lSP = RPM_l(SPi-1);
  dir = sign(RPM_lSP-RPM_li(Ii));
  Vi = Ii+1:SegEndi;
  if dir > 0
    RPM_li(Vi) = ...
      min(RPM_li(Ii) + (T(Vi)-Tk(SPi-1)) * dir * 75, RPM_lSP);
  else
    RPM_li(Vi) = ...
      max(RPM_li(Ii) + (T(Vi)-Tk(SPi-1)) * dir * 75, RPM_lSP);
  end
  RPM_rSP = RPM_r(SPi-1);
  dir = sign(RPM_rSP-RPM_ri(Ii));
  if dir > 0
    RPM_ri(Vi) = ...
      min(RPM_ri(Ii) + (T(Vi)-Tk(SPi-1)) * dir * 75, RPM_rSP);
  else
    RPM_ri(Vi) = ...
      max(RPM_ri(Ii) + (T(Vi)-Tk(SPi-1)) * dir * 75, RPM_rSP);
  end
  Ii = SegEndi;
end
if verb; cla; plot(T,RPM_li,T,RPM_ri); shg; end
%%
Thli = RPM_li.^2/2270;
Thri = RPM_ri.^2/2270;
[mThli,MThli] = bounds(Thli);
RThli = range(Thli);
if verb; cla; plot(T,Thli,T,Thri); shg; end
%%
dTHi = Thli-Thri;
aa = dTHi * TA / I;
aad = rad2deg(aa);
[maad,Maad] = bounds(aad);
Raad = Maad-maad;
if verb; cla; plot(T,aa); shg; end
%%
av = cumsum(aa)*stepSize;
avd = rad2deg(av);
[mavd,Mavd] = bounds(avd);
Ravd = Mavd-mavd;
if verb; cla; plot(T,av); shg; end
%%
ar = cumsum(av)*stepSize;
ard = rad2deg(ar);
[mard,Mard] = bounds(ard);
Rard = Mard-mard;
% Locate the halfway point:
% T_hwpt = interp1(ard,T,(mard+Mard)/2);
i_hwpt = find(ard >= (mard+Mard)/2,1);
T_hwpt = T(i_hwpt);
T_hwptv = T_hwpt*[1 1];
if verb; cla; plot(T,ard); shg; end
%%
figure;
ax = [nsubplot(5,1,1) nsubplot(5,1,2) nsubplot(5,1,3) nsubplot(5,1,4) ...
      nsubplot(5,1,5)];
plot(ax(1),Tk,dThSP,'*',T,dThSPi,T_hwptv,[mdThSPi,MdThSPi],':');
set(ax(1),'ylim',[mdThSPi,MdThSPi]+RdThSPi*lmarg);
ylabel(ax(1),'Newtons');
title(ax(1),'Nominal Rotation');

plot(ax(2),T,Thli,T,Thri,T_hwptv,[mThli,MThli],':');
set(ax(2),'ylim',[mThli,MThli]+RThli*lmarg);
ylabel(ax(2),'Newtons');

plot(ax(3),T,aad,T_hwptv,[maad,Maad],':');
set(ax(3),'ylim',[maad,Maad]+Raad*lmarg);
ylabel(ax(3),'deg/s/s');

plot(ax(4),T,avd,T_hwptv,[mavd,Mavd],':');
set(ax(4),'ylim',[mavd,Mavd]+Ravd*lmarg);
ylabel(ax(4),'deg/s');

plot(ax(5),T,ard,T_hwptv,[mard,Mard],':');
set(ax(5),'ylim',[mard,Mard]+Rard*lmarg);
ylabel(ax(5),'deg');
xlabel(ax(5),'Seconds');

set(ax([2 4]),'YAxisLocation','Right');
set(ax(1:4),'XTickLabel',[]);
shg;
