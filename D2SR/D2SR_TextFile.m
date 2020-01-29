%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   _____ ___   _____ _____    _            _    __ _ _      
%  |  __ \__ \ / ____|  __ \  | |          | |  / _(_) |     
%  | |  | | ) | (___ | |__) | | |_ _____  _| |_| |_ _| | ___ 
%  | |  | |/ / \___ \|  _  /  | __/ _ \ \/ / __|  _| | |/ _ \
%  | |__| / /_ ____) | | \ \  | ||  __/>  <| |_| | | | |  __/
%  |_____/____|_____/|_|  \_\  \__\___/_/\_\\__|_| |_|_|\___|
%                                                            
%                                                                                                                                                                                                                                
%                                                                                               
%   .m script for generating the txt conditions file for a distance to size
%   ratio experiment, or 'Baptiste's thing'
%
% This task is a basic saccade task where after successful completion of a
% fixation hold, a ring target will appear & reward is contingent on
% successfully making a saccade to the center of the target. for the
% training phase of the task, a solid target will appear in the center of
% the ring (where successful fixation is to be held). The contrast of the 
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

function D2SR_TextFile( RF_eccentricity, RF_angle, target_rgb, ...
    target_contrast, target_radius, ring_contrast, ring_thickness,...
    ring_radius, fix_rgb, fix_radius )
%D2SR_TEXTFILE generate the text file for 'D2SR' 
%   D2SR_TextFile takes:
%       1) RF_eccentricity: dva
%       2) RF_angle: deg
%       3) target_rgb: [ x, x, x ] val
%       4) target_contrast: 0-1 scale to modulate rgb val
%       5) target_radius: dva
%       6) ring_contrast: 0-1 scale to modulate rgb val
%       7) ring_thickness: dva
%       8) ring_radius: dva
%       9) fix_rgb: [ x, x, x ] val
%       10) fix_radius: dva  


%task specific
task_folder = 'C:\monkeylogic\Experiments\D2SR';
timing_file = 'D2SR';
fix_fill = 1; %0/1 == open/filled Sqr object


num_conditions = size( target_rgb, 1 ) * size( RF_eccentricity,1 ) * size( ring_radius, 1 ); 
%total number of lines to be added to text conditions file: each color at
%each eccentricity for each ring radius
number_taskObjects = 4;
num_columns = 5 + number_taskObjects;


%use 'sqr' object for fixation
fixation = [ 'Sqr(' num2str( fix_radius ) ',[' num2str( fix_rgb( 1 ) ) ' ' num2str( fix_rgb( 2 ) ) ' '...
    num2str( fix_rgb( 3 ) ) '],' num2str( fix_fill ) ',0,0)' ] ;

bzz_string = 'Snd(sin,0.400,500.000)';
wrongBzz_string = 'Snd(sin,0.400,400.000)';

%create a cell array to hold the entries for the text file
Condition_cell_array = cell( ( num_conditions + 1 ), num_columns ); %preallocate for cell array
Condition_cell_array( 1,: ) = {'Condition', 'Frequency', 'Block', 'Timing File',...
    'TaskObject#1', 'TaskObject#2', 'TaskObject#3', 'TaskObject#4', 'TaskObject#5'}; %header for the cell array
%populate the cell array with trial values
for k = 1:size( target_rgb, 1 )
    for j = 1 : ( length( vec_position ) )
        crc_string = ['Crc(' num2str( target_radius ) ',[' num2str( target_rgb( k,1 ) ) ' ' num2str( target_rgb( k,2 ) ) ' '...
            num2str( target_rgb( k,3 ) ) '],' num2str( target_fill ) ',' vec_position{j}];
        Condition_cell_array( ( j + length( vec_position )*( k-1 ) + 1 ),: ) = { (j + length( vec_position )*( k-1 )),...
            1, 1, timing_file, fixation, crc_string, bzz_string, wrongBzz_string };
    end
end


filen = TaskFileName( timing_file, task_folder );
fid = fopen(filen,'a+t');
WriteMLTable( fid, Condition_cell_array )
fclose(fid);


end