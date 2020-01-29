%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_      _                      _    _____                         _
%      | |    | |                    | |  / ____|                       | |     
%    __| | ___| | __ _ _   _  ___  __| | | (___   __ _  ___ ___ __ _  __| | ___ 
%   / _` |/ _ \ |/ _` | | | |/ _ \/ _` |  \___ \ / _` |/ __/ __/ _` |/ _` |/ _ \
%  | (_| |  __/ | (_| | |_| |  __/ (_| |  ____) | (_| | (_| (_| (_| | (_| |  __/
%   \__,_|\___|_|\__,_|\__, |\___|\__,_| |_____/ \__,_|\___\___\__,_|\__,_|\___|
%   _  _                __/ |      _ ______       _             _      ___      
%  | || |              |___/      | |______|     | |           (_)    |__ \     
%  | || |_   _ __ ___   ___  _ __ | | _____ _   _| | ___   __ _ _  ___   ) |    
%  |__   _| | '_ ` _ \ / _ \| '_ \| |/ / _ \ | | | |/ _ \ / _` | |/ __| / /     
%     | |   | | | | | | (_) | | | |   <  __/ |_| | | (_) | (_| | | (__ / /_     
%     |_|   |_| |_| |_|\___/|_| |_|_|\_\___|\__, |_|\___/ \__, |_|\___|____|    
%                                            __/ |         __/ |                
%                                           |___/         |___/  
% Bonnie Cooper 5/10/2018 bcooper@sunyopt.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% editables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

                                %MonkeyLogic origin is right and goes
                                %counterclockwise
editable('array_angle_min')     %set the angle from the origin for the position of the first target       
editable('array_angle_max')     % " " for the last target position
editable('num_targets')         %number of target placements in the array
editable('eccentricity')        %target eccentricity (deg.vis.ang)
editable('eccentricity2')       %target eccentricity (deg.vis.ang)
editable('eccentricity3')       %target eccentricity (deg.vis.ang)
editable('wait_for_fix')        %interval to wait for fixation to start (msec)
editable('initial_fix')         %hold fixation on fixation_point (msec)
editable('min_delay_fix')       %hold fixation on fixation point while target is toggled on (msec)
editable('delay_fix_increment') %ms to randomly add in random increasing multiple (up to 4) to min_delay_fix 
editable('max_reaction_time')   %max time after initial_fix given to complete a saccade (msec)
editable('hold_target_time')    %hold fixation on bear_image (msec)
editable('fix_radius')          %fixation window (deg.vis.ang)
editable('target_radius')       %target sacade window (deg.vis.ang.)
editable('intTint')             %idle time inbetween conditions (msec)
editable('reward');
editable('num_reward');
editable('pause_reward');

%% send unique strobes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Send Start Experiment Stobes only on the first trial
%this stobes unique values at the start of a new experiment
previousTrialCode = TrialRecord.LastTrialCodes.CodeNumbers; %get the eventmarkers that were sent in the previous trial
formatOut = 31; 
DateStr = datestr(now,formatOut);
disp( DateStr )
bhv_variable('DateStr',DateStr);
DateStrSplit = regexp(DateStr, '[- :]', 'split');
yyyyStrobe = str2num( DateStrSplit{1} );
mmddStrobe = str2num( [ DateStrSplit{2} DateStrSplit{3} ] );
hhmmStrobe = str2num( [ DateStrSplit{4} DateStrSplit{5} ] );
mmssStrobe = str2num( [ DateStrSplit{5} DateStrSplit{6} ] );
if isempty( previousTrialCode ); %if there weren't any eventmarkers this must be the 1st trial
    disp( '¯`·._.··¸.-~*´¨¯¨`*·~-.,-,.-~*´¨¯¨`*·~-.¸··._.·´¯`·._.··¸.-~*´¨¯¨`*·~-.,-,.-~*´¨¯¨`*·~-.¸··._.·´¯' )
    disp( 'start experiment' )
    disp( 'delayedSaccade_ML2' )
    eventmarker( 5555 );
    eventmarker( [ yyyyStrobe mmddStrobe hhmmStrobe mmssStrobe ] );
else
    currentTrialNum = TrialRecord.CurrentTrialNumber;
    eventmarker( 5555 );
    eventmarker( hhmmStrobe );
end

%% task init

%check eye signal input
if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end

showcursor(false);  % remove the joystick cursor
%bhv_code(10,'Fix Cue',20,'Sample',30,'Delay',40,'Go',50,'Reward',60,'Feedback');  % behavioral codes

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;
target = 2;
bzz = 3;


% define time intervals (in ms):
sample_time = 1000;

wait_for_fix = 5000;            %interval to wait for fixation to start
initial_fix = 500;              %hold fixation on fixation_point
min_delay_fix = 500;            %hold fixation on fixation point while target is toggled on (msec)
delay_fix_increment = 50;       %ms to randomly add in random increasing multiple (up to 4) to min_delay_fix    
max_reaction_time = 2000;       %max time after initial_fix given to complete a saccade
hold_target_time = 100;         %hold fixation on target
intTint = 500;                  %time inbetween trials

% initialize variables for target placement
array_angle_min = -45;            %start angle for first posible target pos
array_angle_max = 45;          %end angle for lost posible target pos
num_targets = 4;                %total posible target positions within the
%angle range set by *_max - *_min


%this checks that there is an interval between array_angle_min & array_angle_max
if array_angle_min ~= array_angle_max  %if there is, find possitions spanning the interval
    angle_step = (array_angle_max-array_angle_min)/(num_targets-1);
    %angle of spacing for posible target
    %positions
    target_angles = array_angle_min:angle_step:array_angle_max;
    %anlges of posible target positions
elseif array_angle_min == array_angle_max %if not, just use the single angle value
    target_angles = array_angle_min;
else
    disp( 'error with target_angles value' )
    
end


eccentricity = 10;              %eccentricity of target positions
eccentricity2 = 0;
eccentricity3 = 0;

% fixation & target windows (in deg.vis.ang.):
fix_radius = 3;
target_radius = 4;

reward = 200;
num_reward = 2;
pause_reward = 75;
hotkey('g', 'goodmonkey(400, ''NumReward'', 2,''PauseTime'', 50);' );

if eccentricity2 == 0 && eccentricity3 == 0
    trial_eccentricity = eccentricity;
elseif eccentricity2 ~= 0 && eccentricity3 == 0
    trial_eccentricity = cat( 2, eccentricity, eccentricity2 );
elseif eccentricity3 ~= 0 && eccentricity2 == 0
    trial_eccentricity = cat( 2, eccentricity, eccentricity3 );
elseif eccentricity2 ~= 0 && eccentricity3 ~= 0
    trial_eccentricity = cat( 2, eccentricity, eccentricity2, eccentricity3 );
end

% calculate posible new x- & y-pos for target repositioning
RFmapping_target_pos =  XYTargetPos( target_angles, trial_eccentricity );       
                                %XYTargetPos takes the target_angles & 
                                %eccentricity to calculate target position
                                %values in degvisang for use with
                                %monkeylogic TaskObject parameters
%target_pos_idx = unidrnd( size( RFmapping_target_pos, 1) );
                                %give 1 random number
                                %from 1 to the # of posible target
                                %positions to serve as random index to 
currentTrialNum = TrialRecord.CurrentTrialNumber;
                                %get the current trial number
target_pos_idx = mod( currentTrialNum, size( RFmapping_target_pos, 1 ) ) + 1 ;
reposition_object( 2, RFmapping_target_pos( target_pos_idx, 1 ), ...
    RFmapping_target_pos( target_pos_idx, 2 ) );
                                %reposition_object is a monkeylogic
                                %function that will reposition the target
                                %from the hard coded position specified in
                                %the conditions file to one of the new
                                %positions calulated above
reposition_eccen = RFmapping_target_pos( target_pos_idx, 4 );
reposition_thetaDEG = RFmapping_target_pos( target_pos_idx, 3 );
                                
user_text( [ 'theta = ' num2str( reposition_thetaDEG ) ' @ ' num2str( reposition_eccen ) ] );
                                %user_text is another monkeylogic fxn that
                                %will display the target position (deg) in
                                %the MonkeyLogic control panel. good for
                                %debugging, but can also see the angle
                                %value that is being strobed 

%TrialRecord.RFmapping_target_pos = RFmapping_target_pos;
%TrialRecord.RFmapping_target_pos;

TrialRecord.LastTrialCodes.CodeNumbers;


%% task instances
% scene 1: fixation
fix = SingleTarget(eye_);
fix.Target = fixation_point;
fix.Threshold = fix_radius;
wth1 = WaitThenHold(fix);
wth1.WaitTime = wait_for_fix;
wth1.HoldTime = initial_fix;
scene1 = create_scene(wth1,fixation_point);

% scene 2: delay
delay = WaitThenHold(fix);
delay.WaitTime = 0;
%min_delay_fix + delay_fix_increment*(a random num 1:4)
delaydur = min_delay_fix + delay_fix_increment*(unidrnd(4)-1);
delay.HoldTime = delaydur;
scene2 = create_scene(delay,[ fixation_point, target ] );

% scene 3: target
search = MultiTarget(eye_);
search.Target = target;
search.Threshold = target_radius;
search.WaitTime = max_reaction_time;
search.HoldTime = hold_target_time;
search.TurnOffUnchosen = true;
scene3 = create_scene(search,target );

% scene 4: feedback
fbtc = TimeCounter(null_);
fbtc.Duration = 100;  % duration of the sound, ms
feedback = create_scene(fbtc,bzz);



% scene 5: clear the screen. equivalent to idle(0)
endtrial = TimeCounter(null_);
endtrial.Duration = 0;
endscene = create_scene(endtrial);


%% task control 

%disp('************************************************************************')
%disp('START TRIAL')
%eventmarker 1 == START trial
eventmarker(1);

%initial fixation
run_scene(scene1,10);
if ~wth1.Success
    run_scene(endscene);
    if wth1.Waiting
        %eventmarker 5 == Fixation not acquired
        eventmarker(5);
        trialerror(4); % no fixation
        run_scene(endscene);
    else
        %eventmarker 7 == Fixation break
        eventmarker(7); 
        trialerror(3); % broke fixation
        run_scene(endscene);
    end
    return
end
%eventmarker 3 == Fixation HELD
eventmarker(3)

%disp( 'fixation held' )
fixation_held  = trialtime;


%delay fixation
%eventmarker 71	== Delay ON
%555 is a special marker for neuroexplorer
eventmarker( [ 71 555 ] )
run_scene(scene2,30);
if ~delay.Success
    run_scene(endscene);
    eventmarker(43);
    trialerror(4); 
    return
elseif delay.Success
    eventmarker(46)
end

%target fixation
run_scene(scene3,40);
if ~search.Success
    run_scene(endscene);
    if search.Waiting
        eventmarker(15); 
        trialerror(2); % no or late response (did not land on either the target or distractor)
    else
        eventmarker(16); 
        trialerror(5);  % broke fixation
    end
    return
elseif search.Success
    eventmarker(666)
end
%disp( 'target aquired' )
target_acquired = trialtime;
%disp( target_acquired )

run_scene(endscene);

%% was a direct saccade to target made?
%also, check if the task is in simulation mode 
SimMode_ON = TrialRecord.SimulationMode;
if SimMode_ON
    disp( 'Simulation Mode is On' )
    % saccade to target? then reward & give feedback
    if target==search.ChosenTarget;
        trialerror( 0 ); % correct
        %sound for reward
        run_scene( feedback );
            %eventmarker 98 == Reward ON
    goodmonkey(reward, 'juiceline',1, 'numreward',num_reward, 'pausetime',pause_reward, 'eventmarker',98);
        
    else
        trialerror(6); % chose the wrong (second) object among the options [target distractor]
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
    target_location_X = RFmapping_target_pos( target_pos_idx, 1 );
    target_location_Y = RFmapping_target_pos( target_pos_idx, 2 );
    Tlocation = [ target_location_X target_location_Y ];
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
        %666 is a special marker for neuroexplorer
        eventmarker( [ 13 666 ])
        trialerror( 0 ); % correct
        %sound for reward        
        run_scene( feedback );
            %eventmarker 98 == Reward ON
    goodmonkey(reward, 'juiceline',1, 'numreward',num_reward, 'pausetime',pause_reward, 'eventmarker',98);      
    else
        trialerror(6); %Saccade Away from Target detected
        %eventmarker 15 == Target missed
        eventmarker( 15 ); %Saccade Away from Target detected
        idle(700);
        run_scene(endscene);
        
    end
end

%THIS STROBES A GENERIC PORISITON ID THAT IS USED IN NEUROEXPLORER 
%TO DISPLAY HISTOGRAMS
strobeValue = target_pos_idx*1000;
%disp( strobeValue )
eventmarker(strobeValue);


%end trial
run_scene( endscene );
%eventmarker == 100 END trial
eventmarker(100)

idle( 200 )
