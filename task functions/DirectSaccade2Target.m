function [ directSacc2T ] = DirectSaccade2Target( target_acquired, fixation_held, TargetPos )
%DirectSaccade2Target In the event that a saccade was successfully made to 
%target, this function grabs the eye position data made in the time window 
%from the successful fixation hold to target_aquired. it the returns a bool 
%that is true if the saccade from fixation to target was direct & false if
%it was not. For input, this function needs: 
%1) target_acquired trialtime
%2) fixation_held trialtime
%3) TargetPos



%disp( 'checking for a direct saccade to target' )
%if NOT check that a single saccade was made to target
%saccade detection
saccade_period_timeint = target_acquired - fixation_held;
%the time interval between the end of the delay
%period fixation and the acquisition & fixation of the target
saccade_period_numsamples = saccade_period_timeint + 250;
aisample = get_analog_data('eye', saccade_period_numsamples);
%size( aisample )
%aisample = peekdata(DaqInfo.AnalogInput, saccade_period_numsamples);
%Daq toolbox fxn to preview recently
%aquired data
eyex = aisample(:, 1);
eyey = aisample(:, 2);
%     rawx = aisample(:, 1);
%     rawy = aisample(:, 2);
%     [eyex, eyey] = tformfwd(MLConfig.EyeTransform, rawx, rawy);
%tformfwd is am image processing toolbox
%fxn that performs a forward spatial
%transform. Eyetransform takes the raw x/y
%data and adjusts for the calibration
%transform saved to the configuration file
%size( eyex )
saccade2TargetEyeData = cat( 2, eyex, eyey );
%size( saccade2TargetEyeData )
fixation_positions = SaccadeDetectML( saccade2TargetEyeData );
%disp(fixation_positions)
%SaccadeDetectML returns average
%fixation positions
fixation_positions_test = zeros( size( fixation_positions,1 ), 1 );
target_location_X = TargetPos( 1 );
target_location_Y = TargetPos( 2 );
%disp(target_location_X)
%disp(target_location_Y)
fixation_location = [ 0 0 ];

%TrialRecord.target_radius
for ii = 1:size( fixation_positions,1 );
    target_distance = sqrt((target_location_X - fixation_positions(ii,1))^2 + ...
        (target_location_Y - fixation_positions(ii,2))^2);
    fix_distance = sqrt((fixation_location(1) - fixation_positions(ii,1))^2 + ...
        (fixation_location(2)  - fixation_positions(ii,2))^2);
    %for each detected fixation position,
    %calculate the distance from the
    %fixation position to both the target and
    %fixation location
    if target_distance <= target_radius || fix_distance <= target_radius;
        %if the distance is less than the target
        %window radius for target or fixation
        %locations, then flag the
        %fixation_position_test with a '1'
        fixation_positions_test(ii,1) = 1;
    end
end

%disp(fixation_positions_test)
directSacc2T = false;
if nnz(fixation_positions_test==0);
    %if there is a zero in
    %fixation_positions_test, then one of the
    %fixations was not on the target nor on the
    %fixation point. therefore there was a
    %saccade to somewhere other than the target
    %and this trial should be aborted.
    disp('Saccade away from target')
    directSacc2T = false;
    %return
elseif ~nnz(fixation_positions_test==0);
    disp('Direct saccade to Target')
    directSacc2T = true;
end


end

