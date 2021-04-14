function drawCircle(imsize_dva, LineWidth, centerSize, image_name, path_name, pix_per_deg)
%draw a white circle on a black background
%turn axes, label, etc off
%save Position in pixels w/ correct size for stimulus

%dscribe how to draw a circle
x = 1;
y = 1;
unitSize = 1;
ang=0:0.01:2*pi;
radius = 1/2;
xp=radius*cos(ang);
yp=radius*sin(ang);
%create an figure instance & plto the circle
fig = figure();
plot(x+xp,y+yp,'w','Linewidth', LineWidth);
%make plot limits slightly larger so that circle does not get cropped
pad = 0.01;
ylim( [ 0-pad, 2*unitSize+pad ] );
xlim( [ 0-pad, 2*unitSize+pad ] );
%turn off tick labels + axes
set(gca,'XTick',[]); 
set(gca,'Yticklabel',[]); 
%make axis square, so circle does not get distorted
axis square;
%make background as my coffee
set(gcf,'color','k');
set(gca,'Color','k', 'XColor', 'none', 'YColor', 'none' )
hold on
%add center fixation dot
plot( x,y, 's', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'MarkerSize', centerSize )
%undo some Matlab fuckery:
set(gcf, 'InvertHardcopy', 'off')
image_path = strcat(path_name, image_name);
%set(gca, 'units', 'normalized'); %Just making sure it's normalized
%Tight = get(gca, 'TightInset');  %Gives you the bording spacing between plot box and any axis labels
                                 %[Left Bottom Right Top] spacing
%NewPos = [Tight(1) Tight(2) 1-Tight(1)-Tight(3) 1-Tight(2)-Tight(4)]; %New plot position [X Y W H]
%set(gca, 'Position', NewPos);

%here we set the axis size to render in the right number of pixels to
%generate a stimulus the size we need for the touchscreen
set(findall(fig,'Units','pixels'),'Units','normalized');
fig.Units = 'pixels';
figsize = imsize_dva * round( pix_per_deg );
fig.Position = [0 0 figsize figsize];

print(image_path, '-dtiff')
end


