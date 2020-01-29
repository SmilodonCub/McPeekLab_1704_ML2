%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  _        _______  _        ______   _______  _    _________   _______           
% ( \      (  ___  )( (    /|(  __  \ (  ___  )( \   \__   __/  (  ____ \          
% | (      | (   ) ||  \  ( || (  \  )| (   ) || (      ) (     | (    \/          
% | |      | (___) ||   \ | || |   ) || |   | || |      | |     | |                
% | |      |  ___  || (\ \) || |   | || |   | || |      | |     | |                
% | |      | (   ) || | \   || |   ) || |   | || |      | |     | |                
% | (____/\| )   ( || )  \  || (__/  )| (___) || (____/\| |     | (____/\          
% (_______/|/     \||/    )_)(______/ (_______)(_______/)_(_____(_______/          
%                                                         (_____)                  
%           _______ __________________ _______ _________ _______          _________
% |\     /|(  ____ )\__   __/\__   __/(  ____ \\__   __/(  ____ \|\     /|\__   __/
% | )   ( || (    )|   ) (      ) (   | (    \/   ) (   | (    \/( \   / )   ) (   
% | | _ | || (____)|   | |      | |   | (__       | |   | (__     \ (_) /    | |   
% | |( )| ||     __)   | |      | |   |  __)      | |   |  __)     ) _ (     | |   
% | || || || (\ (      | |      | |   | (         | |   | (       / ( ) \    | |   
% | () () || ) \ \_____) (___   | |   | (____/\   | |   | (____/\( /   \ )   | |   
% (_______)|/   \__/\_______/   )_(   (_______/   )_(   (_______/|/     \|   )_(   
%                                                                                                                                               
%                                                                                 
%                                                                                               
%
%
%   .m script for generating the txt conditions file for landolt C memory guided saccade task.
%
% 
% %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  _        _      __ _ _                                         _             
% | |      | |    / _(_) |                                       | |            
% | |___  _| |_  | |_ _| | ___     __ _  ___ _ __   ___ _ __ __ _| |_ ___  _ __ 
% | __\ \/ / __| |  _| | |/ _ \   / _` |/ _ \ '_ \ / _ \ '__/ _` | __/ _ \| '__|
% | |_ >  <| |_  | | | | |  __/  | (_| |  __/ | | |  __/ | | (_| | || (_) | |   
%  \__/_/\_\\__| |_| |_|_|\___|   \__, |\___|_| |_|\___|_|  \__,_|\__\___/|_|   
%            ______         ______ __/ |                                        
%           |______|       |______|___/                                         
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function memoryGuidedC_TextFile( target_eccentricity, shift_angle, array_rgb, sqr_size, cue_rbg, cue_size, cue_gap, fix_size)
%LANDOLTC_TEXTFILE generate the text file for Landolt_C MonkeyLogic tasks
%and appropriately angled Landolt_C cue images
%   LandoltC_TextFile takes:
%       1) pixperdeg wich can be accessed as MLConfig.PixelsPerDegree once
%       a task has been loaded into the ML main menu. OR it can be viewed
%       in the Video Submenu of the ML main menu
%       2) target eccentricity. int or vec deg.vis.ang. (to generate multiple
%       eccentricities
%       3) shift_angle. degrees. this will shift the target position by a
%       set amount
%       4) target_rgb. any [ m, 3 ] size matrix
%       5) (Optional) cue_size. deg.vis.ang of the LandoltC
%       6) (Optional) cue_gap deg.vis.ang of the LandoltC cue gap


if nargin < 7
    cue_size =  2;
    cue_gap = 0.5;
end


% task_folder: destination & timing_file
task_folder = 'C:\MonkeyLogic2\Experiments\memoryGuidedC';
timing_file = 'memoryGuidedC';

%task specific
num_positions = 4; 
shift_angle = shift_angle * (2*pi) / 360; 
ang_position = ( 0 : ( 2*pi/num_positions ) : 2*pi ) + shift_angle;  %radial position of Crc objects
%sqr_radius =  1 ;   %in degrees of vis. angle
sqr_fill = 1; %0/1 == open/filled Crc object
%fix_size = 0.25; %Sqr object size used for fixation in deg. vis. angle
fix_rgb = [ 1 1 1]; %white fixation dot. can change. totally can.
fix_fill = 1; %0/1 == open/filled Sqr object

expFile = 'C:\MonkeyLogic2\Experiments\popOut_Search\180912_test_popOut_Search_2018_9_11(2).bhv2';
%expFile was last updated 9/12/2018
[~, MLConfigTemplate, ~, ~] = mlread( expFile );
pixperdeg = MLConfigTemplate.PixelsPerDegree( 1 );


Landolt_C = makeLandolt_C( pixperdeg, cue_gap, cue_size, cue_rbg );
mother_image = [ task_folder '\LC' ];
imwrite( Landolt_C, [ mother_image '.bmp' ] );
Landolt_C_name = [ mother_image '.bmp' ];
for i = 1:4
    theta = round( ang_position( i ) * ( 360 / ( 2*pi ) ) );
    task_Lcrc = imread( Landolt_C_name );
    theta_task_Lcrc = imrotate( task_Lcrc, theta );
    task_Lcrc_name = [ mother_image num2str( i ) '.bmp'];
    imwrite( theta_task_Lcrc, task_Lcrc_name );
end


num_task_objects = 7; %fix, 4 target square, 1 landolt_c, 1 bzz
num_conditions = size( array_rgb, 1 ) * length( target_eccentricity ) * num_positions; 
filen = TaskFileName( timing_file, task_folder );
fid = fopen(filen,'a+t');


vec_position =  TargetPositionString( num_positions , target_eccentricity, ang_position( 1 ), ang_position( end ) ); 

%use 'sqr' object for fixation cross fixation cross
fixation = [ 'Sqr(' num2str( fix_size ) ',[' num2str( fix_rgb( 1 ) ) ' ' num2str( fix_rgb( 2 ) ) ' '...
    num2str( fix_rgb( 3 ) ) '],' num2str( fix_fill ) ',0,0)' ] ;

bzz_string = ['Snd(sin,0.400,500.000)'];
bzz2_string = ['Snd(sin,0.400,400.000)'];

%create a cell array to hold the entries for the text file
text_col = 5 + num_task_objects;
Condition_cell_array = cell( ( num_conditions + 1 ), text_col ); %preallocate for cell array
Condition_cell_array( 1,: ) = {'Condition', 'Frequency', 'Block', 'Timing File',...
    'TaskObject#1', 'TaskObject#2', 'TaskObject#3', 'TaskObject#4', 'TaskObject#5', 'TaskObject#6', 'TaskObject#7', 'TaskObject#8' }; %header for the cell array
%populate the cell array with trial values
%count = 0;
for l = 1 : ( size( array_rgb, 1 ) )
    for k = 1 : ( length( target_eccentricity ) )
        for j = 1 : num_positions
            target_string = ['Sqr(' num2str( sqr_size ) ',[' num2str( array_rgb( l,1 ) ) ' ' num2str( array_rgb( l,2 ) ) ' '...
                num2str( array_rgb( l,3 ) ) '],' num2str( sqr_fill ) ',' vec_position{ mod( j,4 ) + 1 } ')'];
            Landolt_C_tag = [ 'LC' num2str( mod( j,4 ) + 1 ) ];
            landolt_C_string = [ 'Pic(' Landolt_C_tag ',0 ,0)' ];
            distractor1_string = ['Sqr(' num2str( sqr_size ) ',[' num2str( array_rgb( l,1 ) ) ' ' num2str( array_rgb( l,2 ) ) ' '...
                num2str( array_rgb( l,3 ) ) '],' num2str( sqr_fill ) ',' vec_position{ mod( j + 1,4 ) + 1 } ')'];
            distractor2_string = ['Sqr(' num2str( sqr_size ) ',[' num2str( array_rgb( l,1 ) ) ' ' num2str( array_rgb( l,2 ) ) ' '...
                num2str( array_rgb( l,3 ) ) '],' num2str( sqr_fill ) ',' vec_position{ mod( j + 2,4 ) + 1 } ')'];
            distractor3_string = ['Sqr(' num2str( sqr_size ) ',[' num2str( array_rgb( l,1 ) ) ' ' num2str( array_rgb( l,2 ) ) ' '...
                num2str( array_rgb( l,3 ) ) '],' num2str( sqr_fill ) ',' vec_position{ mod( j + 3,4 ) + 1 } ')'];
            Condition_cell_array( ( j + 1 + num_positions*( k-1 ) + num_positions*length( target_eccentricity )*( l-1 ) ),: ) = ...
                { ( j + num_positions*( k-1 ) + num_positions*length( target_eccentricity )*( l-1 ) ),...
                1, 1, timing_file, fixation, target_string, distractor1_string, distractor2_string, distractor3_string, landolt_C_string, bzz_string, bzz2_string };
            %count = count + 1
        end
    end
end

%write cell array as a table to a .txt file saved to the path below
WriteMLTable( fid, Condition_cell_array )
fclose(fid);

end

