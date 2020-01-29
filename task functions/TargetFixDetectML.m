function [ target_fix_duration left_cue_test] = CombineCatFixDetectML( eyedata, target_location , target_window_radius)
%TargetFixDetectML tests the eyedata for the duration of a fixation if the
%fixation was within the target_location/window at the end of idleTime.
%This simply takes the sume of eyedata samples where the position was
%within the target window. assumes that idleTime is too brief to make
%multople saccades in and out of target window (may need to change this
%later). also returns left_cue_test = TRUE if eye position leaves the cue
%window during idleTime

%EX: fakeeyedata = [ 0 0; 0 0; 0 0; 8 8; 8 8; 2 2]; target_location=[7,7];
%taget_window_radius=2;
% 
%>> TargetFixDetectML( fakeeyedata, target_location, target_window_radius) 
% 
% ans =
% 
%      2


%find the distance between the x,y eye position data and the target's
%center location
target_distance = sqrt( ( target_location( 1 ) - eyedata( :,1 ) ).^2 + ...
    ( target_location( 2 ) - eyedata( :,2 ) ).^2 );
%inTargetWindow true = all the eyedata values that lie within the target
%position window
inTargetWindow = ~gt( target_distance, target_window_radius );
%total  of true values for inTargetWindow = time spent in target window
%during idleTime (msec)
target_fix_duration = sum( inTargetWindow );

%find the distance between the x,y eye position data and the cue's
%center location
cue_location = [ 0 0 ];
target_distance = sqrt( ( cue_location( 1 ) - eyedata( :,1 ) ).^2 + ...
    ( cue_location( 2 ) - eyedata( :,2 ) ).^2 );
%outCueWindow true = all the eyedata values that lie outside the target
%position window
outCueWindow = gt( target_distance, target_window_radius );
%total of true values for inCueWindow = time spent outside of cue window
%during idleTime (msec)
left_cue_sum = sum( outCueWindow );
%left_cue_test == true is left_cue_sum > 0 | false if left_cue_sum = 0
left_cue_test = any( left_cue_sum );


end





