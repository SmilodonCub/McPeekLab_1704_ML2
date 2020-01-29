function [ name_targets name_distractors ] = ListSortImages( task_folder )
%ListSortImages sorts the image names into seperate target and distractor
%arrays to be indexed in textfile generating functions
%organize lists of target or distractor images
images = dir( [ task_folder,	'\*.bmp'] ); %see the bmp images in this folder's directory
num_images = numel( images ); %count them --> 
num_targets = 0;
name_targets = {};
num_distractors = 0;
name_distractors = {};
for k = 1 : num_images %sort images
    
    image_name = images( k ).name;
    image_cell = cellstr( image_name );
    
    if image_name( 1 ) == 'B'
        num_targets = num_targets + 1;
        name_targets( num_targets ) = image_cell;
        
    elseif image_name( 1 ) == 'D'
        num_distractors = num_distractors + 1;
        name_distractors( num_distractors ) = image_cell;
        
    else
       continue
       
    end
    
end


end

