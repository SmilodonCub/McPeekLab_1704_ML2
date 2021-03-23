sizex = 1024;
sizey = 1024;
[ncols, nrows] = meshgrid(1:sizex, 1:sizey);
centerx = sizex/2;
centery = sizey/2;
R0 = 200;
sig = 8;
gaussring = zeros(sizex,sizey)';
for i=1:500
iR = i;
oR = i+sig;
array2D = (nrows - centery).^2 + (ncols - centerx).^2;
ringPixels = array2D >= iR^2 & array2D <= oR^2;
gaussring = gaussring + ringPixels.*(1/(sig*sqrt(2*pi)))*exp(-((iR-R0)/(2*sig))^2);
end
[val,idx] = max( gaussring(:) );
gaussring = gaussring / val;
figure(1);
surf(gaussring); axis square; shading flat; view(2); colormap('bone'); 
xlim( [0, 1024] ); ylim( [0, 1024] ); set(gca,'XTick',[]); set(gca,'Yticklabel',[])