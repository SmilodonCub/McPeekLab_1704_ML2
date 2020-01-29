function [ name_targets name_distractors ] = CatSearchListSortImages( task_folder, category )
%ListSortImages sorts the image names into seperate target and distractor
%arrays to be indexed in textfile generating functions
%organize lists of target or distractor images
images = dir( [ task_folder,	'\*.bmp'] ); %see the bmp images in this folder's directory
num_images = numel( images ); %count them --> 
disp( num_images );
num_targets = 0;
name_targets = {};
num_distractors = 0;
name_distractors = {};

%category = 'Bear';

if strcmpi(category,'Bear')
    %disp('Bear!')
    targetNameTag = 'TBe';
    distractorNameTag = 'DBe';
elseif strcmpi(category,'BFly')
    disp('BFly!')
    targetNameTag = 'TBF';
    distractorNameTag = 'DBF';
else
    disp('invalid category. Bear or BFly only')
end


for k = 1 : num_images %sort images
    
    
    image_name = images( k ).name;
    %disp(image_name)
    image_cell = cellstr( image_name );
    
    if strcmp(image_name( 1:3 ),targetNameTag)
        num_targets = num_targets + 1;
        name_targets( num_targets ) = image_cell;
        
    elseif strcmp(image_name( 1:3 ),distractorNameTag)
        num_distractors = num_distractors + 1;
        name_distractors( num_distractors ) = image_cell;
        
    else
       continue
       
    end
    
end


end


