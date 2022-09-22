%%
figure;
ax = gca;
plot(ax,[0 1],[0 1]);
set(ax,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);
xlim(ax,[-1 3]);
ylim(ax,[0 1]);
drawnow;
get(ax, 'PlotBoxAspectRatio')
set(ax, 'PlotBoxAspectRatio',[1 1 1]);
drawnow;
get(ax, 'PlotBoxAspectRatio')
