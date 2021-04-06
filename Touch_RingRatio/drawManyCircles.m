function image_names = drawManyCircles( radii,LineWidth, centerSize, directory )
%DRAWMANYCIRCLES creates tiff images of ringtask stimuli
%radii = vector of all radii need images for
%directory = where to save the images

image_names = cell( length( radii ),1 );

for radius = 1:length( radii ) 
    %radii( radius )
    image_name = strcat( 'circ_R', num2str( radii( radius ) ), ...
        '_LW', num2str( LineWidth ), 'cS', num2str( centerSize ) );
    %print( image_name )
    image_names{ radius,1 } = image_name;
    drawCircle( radii( radius ),LineWidth, centerSize, image_name, directory );
end

end

