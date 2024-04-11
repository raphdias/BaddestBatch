clc; clear; close all;
figuretxt = ['Example subplot within subplots'];
F = figure('Name',figuretxt,'NumberTitle','off');
set(F,'WindowState','Fullscreen','Color','White')

T=tiledlayout(F,'Flow','TileSpacing','compact','Padding','none');
for i = 1:4
    t = tiledlayout(T,'flow','TileSpacing','tight','Padding','none');
    t.Layout.Tile = i;
    for J = 1:4
        nexttile(t);
        title(num2str(J))
    end
    title(t,num2str(i))
end

axes(T,'visible','off');
cb = colorbar;
cb.Layout.Tile = 'east';
cb.Label.FontSize = 25;
cb.Label.String = 'Channel Weights';
xlabel(T,'Time (ms)','fontsize',25)
ylabel(T,'Voltage (uV)','fontsize',25)
title(T,figuretxt,'fontsize',25)
export_fig(F,figuretxt)
set(F,'WindowState','normal','WindowStyle','docked')