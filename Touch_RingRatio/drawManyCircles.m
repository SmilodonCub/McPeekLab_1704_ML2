function image_names = drawManyCircles( im_sizes, LineWidth, centerSize, directory, pix_per_deg )
%DRAWMANYCIRCLES creates tiff images of ringtask stimuli
%im_sizes = vector of image sizes in degrees visual angle for a given task
%directory = where to save the images

image_names = cell( length( im_sizes ),1 );

for radius = 1:length( im_sizes ) 
    %radii( radius )
    image_name = strcat( 'circ_R', num2str( im_sizes( radius ) ), ...
        '_LW', num2str( LineWidth ), 'cS', num2str( centerSize ) );
    %print( image_name )
    image_names{ radius,1 } = image_name;
    drawCircle( im_sizes( radius ),LineWidth, centerSize, image_name, directory, pix_per_deg );
end

end

