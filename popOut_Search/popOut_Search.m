%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  _______  _______  _______  _______  _______             _______  _______  _______  _______  _______  ______   _______ 
% (  ____ \(  ____ \(  ___  )(  ____ )(  ____ \|\     /|  (  ____ \(  ___  )(  ____ \(  ____ \(  ___  )(  __  \ (  ____ \
% | (    \/| (    \/| (   ) || (    )|| (    \/| )   ( |  | (    \/| (   ) || (    \/| (    \/| (   ) || (  \  )| (    \/
% | (_____ | (__    | (___) || (____)|| |      | (___) |  | (_____ | (___) || |      | |      | (___) || |   ) || (__    
% (_____  )|  __)   |  ___  ||     __)| |      |  ___  |  (_____  )|  ___  || |      | |      |  ___  || |   | ||  __)   
%       ) || (      | (   ) || (\ (   | |      | (   ) |        ) || (   ) || |      | |      | (   ) || |   ) || (      
% /\____) || (____/\| )   ( || ) \ \__| (____/\| )   ( |  /\____) || )   ( || (____/\| (____/\| )   ( || (__/  )| (____/\
% \_______)(_______/|/     \||/   \__/(_______/|/     \|  \_______)|/     \|(_______/(_______/|/     \|(______/ (_______/
%                                                                                                                                                                                   
%                                                                                 
%                                                                                             
%
%   ML2 timing script for pop-out search saccade task.
%   1) fixation point appears 
%   2) monkey has wait_for_fx msec to fixate & must hold for initial_fix
%   msec within fix_radius (degvisang)
%   3) an array of target/distractors appears & the fixation point
%   disappears
%   4) monkey has max_reaction_time msec to make a saccade to the target
%   within target_radius (degvisang)
%   5) once acquired, monkey must hold fixation on target for
%   hold_target_time msec
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  _   _           _                             _       _    
% | | (_)         (_)                           (_)     | |   
% | |_ _ _ __ ___  _ _ __   __ _   ___  ___ _ __ _ _ __ | |_  
% | __| | '_ ` _ \| | '_ \ / _` | / __|/ __| '__| | '_ \| __| 
% | |_| | | | | | | | | | | (_| | \__ \ (__| |  | | |_) | |_  
%  \__|_|_| |_| |_|_|_| |_|\__, | |___/\___|_|  |_| .__/ \__| 
%                           __/ |                 | |         
%                          |___/                  |_|        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    
                  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% EDITABLE
editable( 'wait_for_fix' );         %interval to wait for fixation to start (msec)
editable( 'initial_fix' );          %hold fixation on fixation_point (msec)
editable( 'delay_time' );
editable( 'max_reaction_time' );    %max time after initial_fix given to complete a saccade (msec)
editable( 'hold_target_time' );     %hold fixation on bear_image (msec)
editable( 'fix_radius' );           %fixation saccade window (deg.vis.ang.)
editable( 'target_radius' );        %target saccade window (deg.vis.ang.)
editable( 'intTint');               %idle time inbetween conditions (msec)
editable('reward');
editable('num_reward');
editable('pause_reward');



%% send unique strobes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Send Start Experiment Stobes only on the first trial
previousTrialCode = TrialRecord.LastTrialCodes.CodeNumbers; %get the eventmarkers that were sent in the previous trial
formatOut = 31;
DateStr = datestr(now,formatOut);
bhv_variable('DateStr',DateStr);
DateStrSplit = regexp(DateStr, '[- :]', 'split');
yyyyStrobe = str2double( DateStrSplit{1} );
mmddStrobe = str2double( [ DateStrSplit{2} DateStrSplit{3} ] );
hhmmStrobe = str2double( [ DateStrSplit{4} DateStrSplit{5} ] );
mmssStrobe = str2double( [ DateStrSplit{5} DateStrSplit{6} ] );
if isempty( previousTrialCode ); %if there weren't any eventmarkers this must be the 1st trial
    disp( '¯`·._.··¸.-~*´¨¯¨`*·~-.,-,.-~*´¨¯¨`*·~-.¸··._.·´¯`·._.··¸.-~*´¨¯¨`*·~-.,-,.-~*´¨¯¨`*·~-.¸··._.·´¯' )
    disp( 'start experiment' )
    disp( 'popOut_Search' )
    eventmarker( 3333 );
    eventmarker( [ yyyyStrobe mmddStrobe hhmmStrobe mmssStrobe ] );
else
    currentTrialNum = TrialRecord.CurrentTrialNumber;
    eventmarker( 3333 );
    eventmarker( hhmmStrobe );
end

%% task init

%check eye signal input
if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end

showcursor(false);  % remove the joystick cursor

% % give names to the TaskObjects defined in the conditions file:
bzz1 = 1;
bzz2 = 2;
fixation_point = 3;
crc1 = 4; crc2 = 5; crc3 = 6; crc4 = 7; crc5 = 8; crc6 = 9; crc7 = 10; ...
    crc8 = 11; crc9 = 12; crc10 = 13; crc11 = 14; crc12 = 15; crc13 = 16; crc14 = 17;
targetobject_array = [fixation_point crc1 crc2 crc3 crc4 crc5 crc6 crc7 ...
    crc8 crc9 crc10 crc11 crc12 crc13 crc14];
target = crc1;
% stimulus_array length is contingent on the how many distractors, so:
num_TaskObjects = length( TrialRecord.CurrentConditionStimulusInfo );
stim_array = targetobject_array( 2:(num_TaskObjects-2));



% define time intervals (in ms):
wait_for_fix = 1000;       %interval to wait for fixation to start (msec)
initial_fix = 300;         %hold fixation on fixation_point (msec)
delay_time = 0;            %an optional delay period
max_reaction_time = 1200;  %max time after initial_fix given to complete a saccade (msec)
hold_target_time = 50;     %hold fixation on image (msec)
intTint = 500;             %idle time inbetween conditions (msec)

% fixation window (in degrees):
fix_radius = 3;
target_radius = 3;

reward = 300;
num_reward = 2;
pause_reward = 75;

hotkey('g', 'goodmonkey( 300 );' );

%get target position (used downstream to check for dirct saccade 2 T )
TargetPos = TrialRecord.CurrentConditionStimulusInfo( 3 ).Position;

%% task scene instances

%scene 1 fixation
fix = SingleTarget( eye_ );
fix.Target = fixation_point;
fix.Threshold = fix_radius;
wth1 = WaitThenHold( fix );
wth1.WaitTime = wait_for_fix;
wth1.HoldTime = initial_fix;
scene1 = create_scene( wth1,fixation_point );

%scene 2 delay ( optional )
if delay_time > 0 %if there is a delay period
    delay = WaitThenHold( fix );
    delay.WaitTime = delay_time;
    %min_delay_fix + delay_fix_increment*(a random num 1:4)
    delaydur = min_delay_fix + delay_fix_increment*(unidrnd(4)-1);
    delay.HoldTime = delaydur;
    scene2 = create_scene(delay,[ fixation_point, stim_array ] );
end

%scene 3 target array presentation
search = MultiTarget( eye_ );
search.Target = target;
search.Threshold = target_radius;
search.WaitTime = max_reaction_time;
search.HoldTime = hold_target_time;
%search.TurnOffUnchosen = true;
scene3 = create_scene( search,stim_array );


%scene 4 feedback
fbtc_Correct = TimeCounter( null_ );
fbtc_Correct.Duration = 100;  % duration of the sound, ms
feedbackCorrect = create_scene( fbtc_Correct,bzz1 );


%scene 4B:endscene Wrong
fbtc_Wrong = TimeCounter( null_ );
fbtc_Wrong.Duration = 500;  % duration of the sound, ms
feedbackWrong = create_scene( fbtc_Wrong,bzz2 );

%scene 5 clear screen
endtrial = TimeCounter( null_ );
endtrial.Duration = 0;
endscene = create_scene( endtrial );

%% task control
%disp('*********************************************************************************************')
%disp('START TRIAL')
%eventmarker 1 == START trial
eventmarker( 1 );

%initial fixation
run_scene( scene1,10 );
if ~wth1.Success
    run_scene( endscene );
    if wth1.Waiting
        eventmarker( 5 );
        trialerror( 4 ); % no fixation
        %run_scene( feedbackWrong );
        run_scene( endscene );
    else
        %eventmarker 7 == Fixation break
        eventmarker( 7 ); 
        trialerror( 3 ); % broke fixation
        %run_scene( feedbackWrong );
        run_scene(endscene);
    end
    return
end
%eventmarker 3 == Fixation HELD
eventmarker( 3 )
%disp( 'fixation held' )

fixation_held  = trialtime;


if delay_time > 0
    %delay_fixation  = trialtime;
    %eventmarker 71	== Delay ON
    eventmarker( 71 )
    run_scene( scene2,30 );
    if ~delay.Success
        run_scene( endscene );
        %eventmarker 73	== Delay NOT acquired
        eventmarker( 73 );
        %run_scene( feedbackWrong );
        trialerror( 4 );
        return
    elseif delay.Success
        %eventmarker 76	== Delay Acquired
        eventmarker( 76 )
    end
    %disp( 'Successful Delay Held' )
end

%target fixation
run_scene(scene3,40);
%eventmarker 21 == Target Array ON
eventmarker( 21 )
if ~search.Success
    run_scene(endscene);
    if search.Waiting
        %eventmarker 24 == Target Array Missed
        eventmarker(24); 
        trialerror(2); % no or late response (did not land on either the target or distractor)
        run_scene( feedbackWrong );
    else
         %eventmarker 25 == Target Array BREAK
         eventmarker(25); 
         trialerror(5);  % broke fixation
         run_scene( feedbackWrong );
     end
    return
elseif search.Success
    %disp( 'Successful Target Hold' )
    %run_scene( feedback );
end

target_acquired = trialtime;
%disp( target_acquired )

%% was a direct saccade to target made?
%also, check if the task is in simulation mode 
SimMode_ON = TrialRecord.SimulationMode;
if SimMode_ON
    disp( 'Simulation Mode is On' )
    % saccade to target? then reward & give feedback
    if target==search.ChosenTarget;
        trialerror( 0 ); % correct
        %sound for reward
        %eventmarker 13 == Target Acquired
        %666 is a special marker for neuroexplorer
        eventmarker( [ 13 666 ])
        run_scene( feedbackCorrect );
            %eventmarker 98 == Reward ON
    goodmonkey(reward, 'juiceline',1, 'numreward',num_reward, 'pausetime',pause_reward, 'eventmarker',98);
        
    else
        trialerror(6); % chose the wrong (second) object among the options [target distractor]
        run_scene( feedbackWrong );
        idle(700);
        
    end
else
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
    %directSacc2T = false;
    if nnz(fixation_positions_test==0);
        %if there is a zero in
        %fixation_positions_test, then one of the
        %fixations was not on the target nor on the
        %fixation point. therefore there was a
        %saccade to somewhere other than the target
        %and this trial should be aborted.
        %disp('Saccade away from target')
        directSacc2T = false;
        %return
    elseif ~nnz(fixation_positions_test==0);
        %disp('Direct saccade to Target')
        directSacc2T = true;
    end
    
    % saccade to target? then reward & give feedback
    if target==search.ChosenTarget && directSacc2T;
        %eventmarker 13 == Target Acquired
        eventmarker( 13 )
        trialerror( 0 ); % correct
        %sound for reward        
        run_scene( feedbackCorrect );
            %eventmarker 98 == Reward ON
    goodmonkey(reward, 'juiceline',1, 'numreward',num_reward, 'pausetime',pause_reward, 'eventmarker',98);   
    else
        trialerror(6); %Saccade Away from Target detected
        %eventmarker 15 == Target missed
        eventmarker( 15 ); %Saccade Away from Target detected
        idle(700);
        run_scene( feedbackWrong );
        run_scene(endscene);
        
    end
end


%end trial
run_scene( endscene );
%eventmarker == 100 END trial
eventmarker(100)

idle( 500 )


