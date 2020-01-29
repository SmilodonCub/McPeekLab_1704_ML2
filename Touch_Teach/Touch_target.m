%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ___________                  .__     
% \__    ___/___  __ __   ____ |  |__  
%   |    | /  _ \|  |  \_/ ___\|  |  \ 
%   |    |(  <_> )  |  /\  \___|   Y  \
%   |____| \____/|____/  \___  >___|  /
%                            \/     \/ 
% ___________                  .__     
% \__    ___/___ _____    ____ |  |__  
%   |    |_/ __ \\__  \ _/ ___\|  |  \ 
%   |    |\  ___/ / __ \\  \___|   Y  \
%   |____| \___  >____  /\___  >___|  /
%              \/     \/     \/     \/ 
% Bonnie Cooper 3/29/2019 bcooper@sunyopt.edu
% Touch_target places a single target in a random position to be held for
% 'hold_touch_time' ms. successful hold == juice reward. the position is 
% changed randomly each trial. this task is to be used to help an NHP learn 
% to interact with the touchscreen.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% editables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 
editable('wait_for_touch')   %max time after initial_fix given to complete a saccade (msec)
editable('hold_touch_time')    %hold fixation on bear_image (msec)
editable('touch_window')       %target sacade window (deg.vis.ang.)
editable('intTint')             %idle time inbetween conditions (msec)
editable('reward');
editable('num_reward');
editable('pause_reward');
editable('eccentricity_limit')

%% send unique strobes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Send Start Experiment Stobes only on the first trial
%this stobes unique values at the start of a new experiment
% previousTrialCode = TrialRecord.LastTrialCodes.CodeNumbers; %get the eventmarkers that were sent in the previous trial
% formatOut = 31; 
% DateStr = datestr(now,formatOut);
% disp( DateStr )
% bhv_variable('DateStr',DateStr);
% DateStrSplit = regexp(DateStr, '[- :]', 'split');
% yyyyStrobe = str2num( DateStrSplit{1} );
% mmddStrobe = str2num( [ DateStrSplit{2} DateStrSplit{3} ] );
% hhmmStrobe = str2num( [ DateStrSplit{4} DateStrSplit{5} ] );
% mmssStrobe = str2num( [ DateStrSplit{5} DateStrSplit{6} ] );
% if isempty( previousTrialCode ); %if there weren't any eventmarkers this must be the 1st trial
%     disp( '¯`·._.··¸.-~*´¨¯¨`*·~-.,-,.-~*´¨¯¨`*·~-.¸··._.·´¯`·._.··¸.-~*´¨¯¨`*·~-.,-,.-~*´¨¯¨`*·~-.¸··._.·´¯' )
%     disp( 'start experiment' )
%     disp( 'Touch Teach' )
%     eventmarker( 5555 );
%     eventmarker( [ yyyyStrobe mmddStrobe hhmmStrobe mmssStrobe ] );
% else
%     currentTrialNum = TrialRecord.CurrentTrialNumber;
%     eventmarker( 5555 );
%     eventmarker( hhmmStrobe );
% end

%% task body

if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
bhv_code(10,'Fix Cue',20,'Sample',30,'Delay',40,'Go',50,'Reward');  % behavioral codes

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;
bzz = 2;

% define time intervals (in ms):
wait_for_touch = 5000;
hold_touch_time = 500;
intTint = 700;

% touch window (in degrees):
touch_window = 5.5;

% outer limit for repositioning the touch target
eccentricity_limit = 5;

reward = 300;
num_reward = 2;
pause_reward = 75;
hotkey('g', 'goodmonkey(400, ''NumReward'', 2,''PauseTime'', 50);' );

%generate a location within eccentricity_limit in pixels
current_mlconfig = mlconfig;
pixperdeg = current_mlconfig.PixelsPerDegree;
new_location = ( -eccentricity_limit + ( eccentricity_limit+eccentricity_limit )*rand( 1,2 ) ); %.* pixperdeg


%move touch target to new location
reposition_object( fixation_point, new_location( 1, 1 ), new_location( 1, 2 ) );

% scene 1: fixation
fix1 = SingleTarget(touch_);     % We use eye signals (eye_) for tracking. The SingleTarget adapter
fix1.Target = fixation_point;  % checks if the gaze is in the Threshold window around the Target.
fix1.Threshold = touch_window;   % The Target can be either TaskObject# or [x y] (in degrees).
wth1 = WaitThenHold(fix1);          % The WaitThenHold adapter waits for WaitTime until the fixation
wth1.WaitTime = wait_for_touch;       % is acquired and then checks if the fixation is held for HoldTime.
wth1.HoldTime = hold_touch_time;        % Since WaitThenHold gets the fixation status from SingleTarget,
                                    % SingleTarget (fix1) must be the input argument of WaitThenHold (wth1).
scene1 = create_scene(wth1,fixation_point);  % In this scene, we will present the fixation_point (TaskObject #1)
                                             % and detect the eye movement indicated by the above parameters.

%scene correct feedback
fbtc_Correct = TimeCounter( null_ );
fbtc_Correct.Duration = 100;  % duration of the sound, ms
feedbackCorrect = create_scene( fbtc_Correct,bzz );

%clear the screen. equivalent to idle(0)
endtrial = TimeCounter(null_);
endtrial.Duration = 0;
endscene = create_scene(endtrial);

% TASK:
run_scene(scene1,10);     % Run the first scene (eventmaker 10)
rt = wth1.AcquiredTime;   % For the reaction time graph
if ~wth1.Success          % If the WithThenHold failed, (either fixation is not acquired or broken during hold)
    idle(0);              % Clear the screen
    if wth1.Waiting       % Check if we were waiting for fixation.
        trialerror(4);    % If so, fixation was never made and this is the "no fixation (4)" error.
    else
        trialerror(3);    % If we were not waiting, it means that fixation was acquired but not held,
    end                   %     so it is the "break fixation (3)" error.
    return
end


% reward
if fixation_point==fix1.Target
    trialerror(0); % correct
    run_scene( feedbackCorrect );
    goodmonkey(reward, 'juiceline',1, 'numreward',num_reward, 'pausetime',pause_reward, 'eventmarker',50); % 100 ms of juice x 2
else
    trialerror(6); % wrong
    run_scene( endscene );
    idle(intTint);
    
idle( intTint );
end

