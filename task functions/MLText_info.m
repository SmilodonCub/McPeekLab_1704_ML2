function MLText_info( task )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 tasks = [{'Saccade_TextFile'};{'SearchSaccade_TextFile'};{'LandoltC_TextFile'};...
     {'TBear_Training_TextFile'};{'TBearSearch_Training_TextFile'}];

if nargin < 1
    disp(tasks)
elseif strcmp( task, tasks(1) )
    disp(task)
    disp('1) target_eccentricity (int or vec; deg.vis.ang.)')
    disp('2) num_position (int)')
    disp('3) angle_range (degrees) max angle to distribute targets ex: 360')
    disp('4) shift_angle (degrees) added to angle range 0:angle_range')
    disp('5) target_rgb any [m,3] matrix of rgb values ex: [ 1 1 1; 0 1 0 ]')
elseif strcmp( task, tasks(2))
    disp(task)
    disp('1) target_eccentricity (int; deg.vis.ang.)')
    disp('2) num_positions (int or vec)')
    disp('3) shift_angle (degrees) shift target position by shift_angle degrees')
    disp('4) target_rgb any [m,3] matrix. distractor rgb will shift 1 row')
    disp('5) target_radius  (deg.vis.ang.)')
elseif strcmp( task, tasks(3))
    disp(task)
    disp('1) pixperdeg (int/float)')
    disp('2) target_eccentricity (int; deg.vis.ang.)')
    disp('3) shift_angle (degrees) shift target position by shift_angle degrees')
    disp('4) target_rgb any [m,3] matrix.')
    disp('5) cue_size (deg.vis.ang.)')
    disp('6) cue_gap (deg.vis.ang.)')
elseif strcmp( task, tasks(4))
    disp(task)
    disp('1) target_eccentricity (int; deg.vis.ang)')
    disp('2) fix_size (int; deg.vis.ang)')
    disp('3) target_index_id (int) sets the target image')
elseif strcmp( task, tasks(5))
    disp(task)
    disp('1) target_eccentricity (int; deg.vis.ang)')
    disp('2) shift_angle (degrees) shift target position')
    disp('3) num_conditions (int) arbitrary number of unique targer/distractor sets')
    disp('4) cue_size (int; deg.vis.ang) size of fixation during target/distractor presentation')
    disp('5) fix_size (int; deg.vis.ang.) fixation size otherwise')
    disp('6) target_index_id (int) sets the target image')
else
    disp('NONE FOUND')
end

