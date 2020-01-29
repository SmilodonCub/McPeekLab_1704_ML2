function [ vec_position ] = TargetPositionString( num_targets, eccentricity, angle_min, angle_max )
%TARGETPOSITIONSTRING takes in the number of target positions (int), the target
%eccentricity , angle_min, and angle_max and returns an array for
%formatted strings to be used in MonkeyLogic tasks.

%FOR EXAMPLE:
% TargetPositionString( 4, 10, 0, 2*pi )
% 
% ans = 
% 
%     '10,0)'
%     '0,10)'
%     '-10,0)'
%     '0,-10)'
%
% these strings are then concatenated onto the rest of the TargetObject
% fields in the conditions.txt doc

tolerance = 1e-6; %when to round trig maths to zero.
%this is done just for readability of the text file output.
%this tolerance ( 1e-6 ) is much lower than screen resolution,
%so there is no effect on the task for doing this

vec_position = cell( length( eccentricity ) * num_targets,1 ); %an array of strings. each string has the formated 
%postition vectors in deg of visual angle to be used in MonkeyLogic for
%positioning stimuli

ang_position = angle_min : ( angle_max - angle_min )/num_targets : angle_max ;
%calculate the target position vectors & make formated strings
%calculate the target position vectors & make formated strings
for m = 1:length( eccentricity )
    for n = 1:num_targets
        vec_pos_x = eccentricity( m ) * cos( ang_position( n ) );
        if abs( vec_pos_x ) < tolerance
            vec_pos_x = 0;
        end
        vec_pos_xstr = num2str( vec_pos_x,'%.2f' );
        vec_pos_y = eccentricity( m ) * sin( ang_position( n ) );
        if abs( vec_pos_y ) < tolerance
            vec_pos_y = 0;
        end
        vec_pos_ystr = num2str( vec_pos_y,'%.2f' );
        vec_position( n + num_targets * ( m-1 ) ) = { [ vec_pos_xstr ',' vec_pos_ystr ] };
    end
end



end

