%%
% Run scratch_220912.m for runidx 3 first to load data
% Also run scratch_220911.m for runidx3 to get dGPSheight
% Impulse Analysis
RPMnz = D.PMC_Left_RPM_SP ~= 0 | D.PMC_Right_RPM_SP ~= 0;
starts = find(diff(T1 < 24894 & RPMnz) > 0);
ends = [starts(2:end); find(T1<24894,1,'last')];
V1 = D.Nav_dThrust_pct > 0;
T1V = T1(V1);
ax = nsubplots(2);
plot(ax(1),T1V,D.PMC_Left_RPM_SP(V1),T1V,D.PMC_Right_RPM_SP(V1), ...
    T1(starts),D.PMC_Left_RPM_SP(starts),'*r', ...
    T1(ends),D.PMC_Left_RPM_SP(ends),'*b');
ylabel(ax(1),'RPM');
legend(ax(1),'Port','Starboard');
title(ax(1),runname);

V10 = T10 >= T1V(1) & T10 <= T1V(end);
plot(ax(2),T10(V10),F.height(V10));
ylabel(ax(2),'GPS Alt m');
xlabel(ax(2),'Seconds since midnight UTC');

set(ax(1:end-1),'XTickLabels',[]);
set(ax(2:2:end),'YAxisLocation','Right');
linkaxes(ax,'x');
%
Tstarts = T1(starts);
Tends = T1(ends);
%%
heading_uw = heading+dheading;
dThrusts = zeros(length(starts),1);
RopeLens = zeros(length(starts),1);
TurnDegs = zeros(length(starts),1);
Overshoot = zeros(length(starts),1);
fig = figure;
ax = [ subplot(1,2,1) subplot(1,2,2) ];
menu_selection = 0;
mtop = uimenu(fig,'Text','&Animation');
mitem = uimenu(mtop,'Text','Stop');
mitem.MenuSelectedFcn = @(src,event)assignin('base','menu_selection',1);
mitem = uimenu(mtop,'Text','Next');
mitem.MenuSelectedFcn = @(src,event)assignin('base','menu_selection',2);
mitem = uimenu(mtop,'Text','Memory');
mitem.MenuSelectedFcn = @(src,event)memory;
vgain = 3;
[payload,gps_offset,payload_hw] = payload_shp;
pause;
for i=1:length(starts) % :-1:1 don't go backwards
  if menu_selection == 1; break; end
  Vpulse = T10 >= Tstarts(i) & T10 <= Tends(i);
  T10V = T10(Vpulse);
  hdV = heading_uw(Vpulse);
  trkV = F.Track(Vpulse);
  VP1 = T1 >= Tstarts(i) & T1 <= Tends(i);
  dT10V = T10V-T10V(1);

  R = [cosd(hdV) sind(hdV)];
  ref_offset = -gps_offset + [payload_hw/2,-payload_hw/5];
  Off = [ref_offset; [ref_offset(2) -ref_offset(1)]];

  h = plot(ax(1),dT10V,hdV,[0 0],[min(hdV) max(hdV)]);
  xlabel(ax(1),'Seconds');
  ylabel(ax(1),'Heading deg');
  title(ax(1),sprintf('Impulse %d of %d',i,length(starts)));
  east_m = F.east_m(Vpulse);
  east_m = east_m - east_m(1);
  north_m = F.north_m(Vpulse);
  north_m = north_m - north_m(1);
  pos = [east_m north_m]; % position of the Spatial Dual
  posoff = R * Off + pos; % position at refps_offset from Spatial Dual
  v_fwd = F.velocity_forward(Vpulse);
  for j=1:5:length(T10V)
    if menu_selection == 1; break; end
    if menu_selection == 2; menu_selection = 0; break; end
    
    % Trace the position of the Spatial Dual
    % plot(ax(2),east_m(1:j),north_m(1:j));

    % Trace the position of the center of the payload
    plot(ax(2), posoff(1:j,1),posoff(1:j,2));

    set(ax(2),'DataAspectRatio',[1 1 1]); % ,'PlotBoxAspectRatio',[1 1 1]);
    % Attempt here to set a minimum size. Not great.
    % xlim(ax(2),[min(east_m)-len max(east_m)+len]);
    %xlim(ax(2),posoff(j,1) + [-2.5 2.5]);
    %ylim(ax(2),posoff(j,2) + [-2.5 2.5]);

    % I want to have limits at least 2.5 meters from the reference position. As
    % the reference position moves, we have to zoom out a bit.
    xposlim = [ min(posoff(1:j,1)) max(posoff(1:j,1))];
    yposlim = [ min(posoff(1:j,2)) max(posoff(1:j,2))];
    xposrange = diff(xposlim);
    yposrange = diff(yposlim);
    posrange = max(xposrange,yposrange)+5;
    xlim(ax(2),xposlim+(posrange-xposrange)*[-1 1]/2);
    ylim(ax(2),yposlim+(posrange-yposrange)*[-1 1]/2);

    len = payload_hw*0.75; %0.25 * (max(east_m) - min(east_m)); % vgain*v_fwd(j),0.4);
    shape(ax(2), payload, hdV(j), pos(j,:), 'k');
    arrow(ax(2), posoff(j,:), hdV(j), len,'r');
    arrow(ax(2), posoff(j,:), trkV(j), vgain*v_fwd(j),'b');
    h(2).XData = [1 1] * dT10V(j);
    grid(ax(2),'on');
    drawnow;
    if j==1; pause(1); end
  end
  pause(1);
end
%%
function shape(ax, shp, heading, pos, color)
  % shape(ax, shp, pos, heading, color)
  % ax: axes on which to draw
  % shp: Nx2 shape definition X and Y columns in meters
  % heading: angle in degrees to rotate the shape
  % pos: [x,y] offset applied after rotation, in meters
  % color: standard plot() line type character string
  R = [cosd(heading), -sind(heading); sind(heading) cosd(heading)];
  shp = shp*R;
  shp = shp + ones(size(shp,1),1)*pos;
  hold(ax,'on');
  plot(ax,shp(:,1),shp(:,2),color);
  hold(ax,'off');
end

function shp = arrow_shp(len)
  shp = [
     0, 0
     0, len
    -0.04*len, 0.9*len
     0.04*len, 0.9*len
     0, len
    ];
end

function arrow(ax, pos, heading, len, color)
  shape(ax, arrow_shp(len), heading, pos, color);
end
% arrow_p = [
%    0, 0
%    0, len
%   -0.04*len, 0.9*len
%    0.04*len, 0.9*len
%    0, len
%   ];
% R = [cosd(heading), -sind(heading); sind(heading) cosd(heading)];
% arrow_p = arrow_p * R;
% arrow_p = arrow_p + ones(size(arrow_p,1),1)*pos;
% hold(ax,'on');
% plot(ax,arrow_p(:,1),arrow_p(:,2),color);
% hold(ax,'off');

function [shp,gps_off_out,hw_out] = payload_shp
  hw = 1.25/2; % main cube half width
  bhl = hw+1.24; % beam half length
  bw = 0.067; % beam width
  by = -hw + 0.195; % aft face of the beam
  pdy = -0.168; % prop offset from aft face of beam
  pr = 0.2; % arbitrary prop radius
  gps_offset = [hw-0.38, hw-0.23];
  shp = [
    -hw, -hw
    -hw,  hw,
     hw,  hw,
     hw, -hw,
    -hw, -hw,
    NaN, NaN,
    -bhl, by,
     bhl, by,
     bhl, by+pdy,
     bhl+pr, by+pdy,
     bhl-pr, by+pdy,
     bhl, by+pdy,
     bhl, by+bw,
     -bhl, by+bw,
     -bhl, by+pdy,
     -bhl+pr, by+pdy,
     -bhl-pr, by+pdy,
     -bhl, by+pdy
    ];
  shp = shp - ones(size(shp,1),1)*gps_offset;
  if nargout > 1; gps_off_out = gps_offset; end
  if nargout > 2; hw_out = hw; end
end

