function [ vec_position ] = Random4PositionString( random_stream, eccentricity, angle_min_separation )
%TARGETPOSITIONSTRING takes in the number of target positions (int), the target
%eccentricity , angle_min, and angle_max and returns an array for
%formatted strings to be used in MonkeyLogic tasks.

%FOR EXAMPLE:
% Random4PositionString( stream, 10, target_angle )
% 
% ans = 
% 
%     '10,0'
%     '0,10'
%     '-10,0'
%     '0,-10'
%
% these strings are then concatenated onto the rest of the TargetObject
% fields in the conditions.txt doc

tolerance = 1e-6; %when to round trig maths.
%this is done just for readability of the text file output.
%this tolerance ( 1e-6 ) is much lower than screen resolution,
%so there is no effect on the task for doing this

num_targets = 4;
vec_position = cell( num_targets,1 ); %an array for strings. 

%

find_pos = 0;
    %pick a randomly pick 4 positions in deg
    %order from small to large
    %find the angle between each position
    %are these positions separated by at least anlge_mi_separation?
while find_pos == 0
    pos = sort(randi( random_stream, 360, [4,1] ));
    posshift = circshift( pos, 1 );  posshift(1) = -(360-posshift(1));
    posdif = pos - posshift; smallest = min( posdif );
    if smallest >= angle_min_separation
        find_pos = 1;
    end
end

%ang_position = angle_min : ( angle_max - angle_min )/num_targets : angle_max ;

for m = 1:length( eccentricity )
    for n = 1:num_targets
        vec_pos_x = eccentricity( m ) * cosd( pos( n ) );
        if abs( vec_pos_x ) < tolerance
            vec_pos_x = 0;
        end
        vec_pos_xstr = num2str( vec_pos_x );
        vec_pos_y = eccentricity( m ) * sind( pos( n ) );
        if abs( vec_pos_y ) < tolerance
            vec_pos_y = 0;
        end
        vec_pos_ystr = num2str( vec_pos_y );
        vec_position( n + num_targets * ( m-1 ) ) = { [ vec_pos_xstr ',' vec_pos_ystr ] };
    end
end
