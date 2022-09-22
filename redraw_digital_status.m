function redraw_digital_status(h,status)
% redraw_digital_status(h, status)
% h is a graphics handle of line plot of a digital status variable with
% integer values.
% status is a cell array of strings for individual status values. status{N}
% is the label for status value N-1, so we are assuming the status values
% are small non-negative integers.

% Common digital status display (stripping out unused values)
ax = h.Parent;
Nstatus = length(status);
Input = h.YData;
U = unique(Input);
NU = length(U);
offset = 1-min(U);
if NU > 1
  V = interp1(U,1:NU,min(U):max(U),'nearest')';
else
  V = 1;
end
SV = V(Input+offset);
h.YData = SV;
h.LineStyle = 'none';
h.Marker = '.';
% Handle values out of range
for i = max(U)+1:-1:Nstatus+1
  status{i} = sprintf('%d',i);
end
set(ax,'YTick',1:NU,'YTickLabels', status(U+1),'YLim',[0.9 NU+0.1]);
