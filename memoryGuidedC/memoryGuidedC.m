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
%                                                                                               
%
%
%   .m script for generating the txt conditions file for landolt C memory guided saccade task.
%
% 
% %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%LoadEventCodes_MCPKLB                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% editables
editable( 'wait_for_fix' );         %interval to wait for fixation to start
editable( 'initial_fix' );          %hold fixation on fixation_point
editable( 'cuehold_fix' );           %interval between fixation and cue presentation
editable( 'cuego_fix' );              %hold fixation during cue presentation
editable( 'total_search_time' );    %max time after initial_fix given to complete a saccade
editable( 'hold_target_time' );     %hold fixation on bear_image
editable( 'fix_radius' ); 
editable( 'target_radius' );
editable('reward');
editable('num_reward');
editable('pause_reward');

%% unique mark-up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Send Start Experiment Stobes
trialcodenum = TrialRecord.LastTrialCodes.CodeNumbers; %get the eventmarkers that were sent in the previous trial
formatOut = 31;
DateStr = datestr(now,formatOut);
%disp( DateStr )
bhv_variable('DateStr',DateStr);
DateStrSplit = regexp(DateStr, '[- :]', 'split');
yyyyStrobe = str2double( DateStrSplit{1} );
mmddStrobe = str2double( [ DateStrSplit{2} DateStrSplit{3} ] );
hhmmStrobe = str2double( [ DateStrSplit{4} DateStrSplit{5} ] );
mmssStrobe = str2double( [ DateStrSplit{5} DateStrSplit{6} ] );
if isempty( trialcodenum ); %if there weren't any eventmarkers this must be the 1st trial
    disp( '¯`·._.··¸.-~*´¨¯¨`*·~-.,-,.-~*´¨¯¨`*·~-.¸··._.·´¯`·._.··¸.-~*´¨¯¨`*·~-.,-,.-~*´¨¯¨`*·~-.¸··._.·´¯' )
    disp( 'start experiment' )
    disp( 'memoryGuidedC' )
    eventmarker( 4444 );
    eventmarker( [ yyyyStrobe mmddStrobe hhmmStrobe mmssStrobe ] );
else
    currentTrialNum = TrialRecord.CurrentTrialNumber;
    eventmarker( 4444 );
    eventmarker( hhmmStrobe );
end


%% task init
%time intervals (in ms):
wait_for_fix = 2000;        %interval to wait for fixation to start
initial_fix = 500;          %hold fixation on fixation_point
no_wait_for_fix = 10;       %this is super low, because fix should already be at fix pnt
cuehold_fix = 200;           %interval between fixation & cueing
cuego_fix = 1000;             %hold fixation during cue presentation
total_search_time = 4000;   %max time after initial_fix given to complete a saccade
hold_target_time = 50;      %hold fixation on image

% fixation window (in deg.vis.ang.):
fix_radius = 5;
target_radius = 5;

%give names to the TaskObjects defined in the conditions file:
fixation_point = 1;
target = 2;
distractor1 = 3;
distractor2 = 4;
distractor3 = 5;
cue = 6;
bzz = 7;
bzz2 = 8;

stim_array = [ target, distractor1, distractor2, distractor3 ];

reward = 300;
num_reward = 2;
pause_reward = 75;

hotkey('g', 'goodmonkey( 300 );' );

%get target position (used downstream to check for dirct saccade 2 T )
TargetPos = TrialRecord.CurrentConditionStimulusInfo( 2 ).Position;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% task scene instances

%scene 1 fixation at fixation point
fix = SingleTarget( eye_ );
fix.Target = fixation_point;
fix.Threshold = fix_radius;
wth1 = WaitThenHold( fix );
wth1.WaitTime = wait_for_fix;
wth1.HoldTime = initial_fix;
scene1 = create_scene( wth1,[ fixation_point, stim_array ] );

%scene 2a cue hold ( with fixation pnt )
cuehold = SingleTarget( eye_ );
cuehold.Target = fixation_point;
cuehold.Threshold = fix_radius;
wth2 = WaitThenHold( cuehold );
wth2.WaitTime = no_wait_for_fix; %is necessary?
wth2.HoldTime = cuehold_fix;
scene2a = create_scene( wth2,[ fixation_point, cue, stim_array ]);

%scene 2b cue GO ( with fixation pnt )
cuego = MultiTarget( eye_ );
cuego.Target = target;
cuego.Threshold = target_radius;
cuego.WaitTime = cuego_fix; %is necessary?
cuego.HoldTime = hold_target_time;
scene2b = create_scene( cuego,[ cue, stim_array ]);


%scene 3 target array presentation
search = MultiTarget( eye_ );
search.Target = target;
search.Threshold = target_radius;
array_search_time = total_search_time - cuego_fix;
search.WaitTime = array_search_time;
search.HoldTime = hold_target_time;
%search.TurnOffUnchosen = true;
scene3 = create_scene( search, stim_array );


%scene 4A positive feedback
fbtc_Correct = TimeCounter( null_ );
fbtc_Correct.Duration = 100;  % duration of the sound, ms
feedbackCorrect = create_scene( fbtc_Correct,bzz );

%scene 4B negative feedback
fbtc_Wrong = TimeCounter( null_ );
fbtc_Wrong.Duration = 500;  % duration of the sound, ms
feedbackWrong = create_scene( fbtc_Wrong, bzz2 );

%scene 5 clear screen
endtrial = TimeCounter( null_ );
endtrial.Duration = 0;
endscene = create_scene( endtrial );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% task control
%disp('______________________________________________________________________')
%disp('START TIRAL')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%eventmarker 1 == START trial
eventmarker(1);

%initial fixation
run_scene( scene1,10 );
if ~wth1.Success
    run_scene( endscene );
    if wth1.Waiting
        %eventmarker 5 == Fixation not acquired
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

% cue presentation & fixation hold at fix pnt
%initial fixation
if cuehold_fix > 0
    run_scene( scene2a,10 );
    if ~wth2.Success
        run_scene( endscene );
        if wth2.Waiting
            %eventmarker 33	== Cue NOT aquired
            eventmarker( 33 );
            trialerror( 4 ); % no fixation
            %run_scene( feedbackWrong );
            run_scene( endscene );
        else
            %eventmarker 35	== Cue BREAK fixation
            eventmarker( 35 );
            trialerror( 3 ); % broke fixation
            %run_scene( feedbackWrong );
            run_scene(endscene);
        end
        return
    end
end
%eventmarker 36	== Cue Aquired
eventmarker( 36 )
%disp( 'Fixation' )
%disp( 'cuehold held' )

cuego_2target = 0;
if cuego_fix > 0
    run_scene( scene2b,10 );
    if ~cuego.Success
        %disp( 'no cuego_fix saccade to target' )
        %run_scene( endscene );
        %eventmarker 63	== CueGo NOT aquired
        eventmarker( 63 )
    end
else
    %disp( 'saccade to target w/in cuego_fix' )
    cuego_2target = 1;
end


if cuego_2target == 0
    %target fixation
    run_scene(scene3,40);
    if ~search.Success
        %disp( 'no search saccade to target' )
        run_scene(endscene);
        if search.Waiting
            %eventmarker 63 == CueGo NOT aquired
            eventmarker(63);
            trialerror(2); % no or late response (did not land on either the target or distractor)
            run_scene( feedbackWrong );
            run_scene(endscene);
        else
            %eventmarker 65 == CueGo BREAK fixation
            eventmarker(65);
            trialerror(5);  % broke fixation
            run_scene( feedbackWrong );
            run_scene(endscene);
        end
        return
    elseif search.Success
        %disp( 'Successful Target Hold' )
        %run_scene( feedback );
    end
end

target_acquired = trialtime;
%disp( target_acquired )


%% was a direct saccade to target made?
%also, check if the task is in simulation mode 
SimMode_ON = TrialRecord.SimulationMode;
if SimMode_ON
    %disp( 'Simulation Mode is On' )
    % saccade to target? then reward & give feedback
    if search.Success || cuego.Success;
        %eventmarker 26	== Target Array Aquired
        eventmarker( 26 )
        trialerror( 0 ); % correct
        %sound for reward
        run_scene( feedbackCorrect );
        run_scene( endscene );
            %eventmarker 98 == Reward ON
    goodmonkey(reward, 'juiceline',1, 'numreward',num_reward, 'pausetime',pause_reward, 'eventmarker',98);
        
    else
        %eventmarker 23 == Target Array Aquired
        eventmarker( 23 )
        trialerror(6); % chose the wrong (second) object among the options [target distractor]
        run_scene( feedbackWrong );
        run_scene( endscene );
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
        %eventmarker 26	== Target Array Aquired
        eventmarker(26); 
        trialerror( 0 ); % correct
        %sound for reward        
        run_scene( feedbackCorrect );
        run_scene( endscene );
            %eventmarker 98 == Reward ON
    goodmonkey(reward, 'juiceline',1, 'numreward',num_reward, 'pausetime',pause_reward, 'eventmarker',98);
    else
        %eventmarker 23 == Target Array Aquired
        eventmarker( 23 )
        trialerror(6); %Saccade Away from Target detected
        idle(700);
        run_scene( feedbackWrong );
        run_scene(endscene);
        
    end
end


%end trial
%run_scene( endscene );
%eventmarker == 100 END trial
eventmarker( 100 )

idle( 200 )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 