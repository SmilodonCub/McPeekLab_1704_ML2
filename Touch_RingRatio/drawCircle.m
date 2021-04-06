function drawCircle(radius,LineWidth, centerSize, image_name, path_name)
%x and y are the coordinates of the center of the circle
%r is the radius of the circle
%0.01 is the angle step, bigger values will draw the circle faster but
%you might notice imperfections (not very smooth)
x = 4;
y = 4;
largestC = 4;
ang=0:0.01:2*pi; 
xp=radius*cos(ang);
yp=radius*sin(ang);
fig = figure();
plot(x+xp,y+yp,'w','Linewidth', LineWidth);
pad = 0.1;
ylim( [ 0-pad, 2*largestC+pad ] );
xlim( [ 0-pad, 2*largestC+pad ] );
set(gca,'XTick',[]); 
set(gca,'Yticklabel',[]); 
axis square;
set(gcf,'color','k');
set(gca,'Color','k', 'XColor', 'none', 'YColor', 'none' )
hold on
plot( x,y, 's', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'MarkerSize', centerSize )
set(gcf, 'InvertHardcopy', 'off')
image_path = strcat(path_name, image_name);
print(image_path, '-dtiff')
end


